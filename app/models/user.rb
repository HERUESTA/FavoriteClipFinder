class User < ApplicationRecord
  # アソシエーション
  has_many :playlists, foreign_key: "user_uid", primary_key: "uid", dependent: :destroy
  has_many :favorite_clips, foreign_key: "user_uid", primary_key: "uid", dependent: :destroy
  has_many :favorited_clips, through: :favorite_clips, source: :clip
  has_many :likes, foreign_key: "user_uid", primary_key: "uid", dependent: :destroy
  has_many :liked_playlists, through: :likes, source: :playlist
  has_many :follows, dependent: :destroy
  has_many :streamers, through: :follows

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :omniauthable, omniauth_providers: [ :twitch ]

  # uidを元にユーザーを検索または作成し、トークンがない場合や期限が切れている場合は更新
  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_create! do |u|
      u.user_name = auth.info.name
      u.email = auth.info.email
      u.profile_image_url = auth.info.image
    end

    # ユーザーが新規作成された場合、トークン情報を保存
    if user.new_record? || user.access_token.nil? || user.token_expires_at.nil? || user.token_expires_at < Time.now
      Rails.logger.debug "トークンが無効または期限切れ、再取得を行います。"
      user.access_token = auth.credentials.token
      user.refresh_token = auth.credentials.refresh_token
      user.token_expires_at = Time.at(auth.credentials.expires_at) if auth.credentials.expires
      user.save! # 新しいユーザーまたは更新された場合に保存
    else
      Rails.logger.debug "有効なアクセストークンが既に存在します。"
    end

    # フォローリストの取り込み
    user.import_follows

    user
  end

  # アクセストークンを再取得するロジック
  def refresh_access_token
    if refresh_token.blank?
      Rails.logger.error "リフレッシュトークンが存在しません。"
      return
    end

    response = Faraday.post("https://id.twitch.tv/oauth2/token") do |req|
      req.body = {
        client_id: ENV["TWITCH_CLIENT_ID"],
        client_secret: ENV["TWITCH_CLIENT_SECRET"],
        refresh_token: refresh_token,
        grant_type: "refresh_token"
      }
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"
    end

    if response.success?
      token_data = JSON.parse(response.body)
      update(
        access_token: token_data["access_token"],
        refresh_token: token_data["refresh_token"],
        token_expires_at: Time.now + token_data["expires_in"].to_i.seconds
      )
      Rails.logger.debug "アクセストークンの再取得に成功しました！"
    else
      Rails.logger.error "アクセストークンの再取得に失敗しました: #{response.body}"
    end
  end

    # アクセストークンをリフレッシュするメソッド
    def refresh_access_token(user)
      response = Faraday.post("https://id.twitch.tv/oauth2/token") do |req|
        req.body = {
          client_id: ENV["TWITCH_CLIENT_ID"],
          client_secret: ENV["TWITCH_CLIENT_SECRET"],
          refresh_token: user.refresh_token,
          grant_type: "refresh_token"
        }
        req.headers["Content-Type"] = "application/x-www-form-urlencoded"
        Rails.logger.debug "リクエストの内容: #{req.headers}"
      end

      if response.success?
        token_data = JSON.parse(response.body)
        user.update(
          access_token: token_data["access_token"],
          refresh_token: token_data["refresh_token"],
          token_expires_at: Time.now + token_data["expires_in"].to_i.seconds
        )
      else
        Rails.logger.debug "リクエストに失敗しました"
      end
    end

    def import_follows
      Rails.logger.debug "フォローリストの取り込みを開始します。"

      # ユーザーのTwitch IDを取得
      twitch_user_id = fetch_twitch_user_id
      unless twitch_user_id
        Rails.logger.error "TwitchユーザーIDの取得に失敗しました。"
        return
      end

      # フォローリストを取得
      follows = fetch_follow_list(twitch_user_id)
      unless follows
        Rails.logger.error "フォローリストの取得に失敗しました。"
        return
      end

      Rails.logger.debug "取得したフォロー数: #{follows.size}"

      # 配信者ごとの詳細情報を補完
      follows.each do |followed_user|
        # 必要なデータの存在を確認
        if followed_user["broadcaster_id"].blank?
          Rails.logger.error "不完全なデータをスキップしました: #{followed_user.inspect}"
          next
        end

        # 配信者の詳細情報を取得
        user_details = fetch_streamer_details(followed_user["broadcaster_id"])

        if user_details.nil?
          Rails.logger.error "配信者情報の取得に失敗しました: #{followed_user['broadcaster_id']}"
          next
        end

        # 配信者テーブルに配信者が存在するか確認
        streamer = Streamer.find_or_initialize_by(streamer_id: followed_user["broadcaster_id"])

        # 配信者が存在しない場合は登録
        if streamer.new_record?
          streamer.streamer_name = user_details["login"]
          streamer.display_name = user_details["display_name"]
          streamer.profile_image_url = user_details["profile_image_url"]

          if streamer.save
            Rails.logger.debug "新しい配信者を登録しました: #{streamer.display_name} (ID: #{streamer.streamer_id})"
          else
            Rails.logger.error "配信者の登録に失敗しました: #{followed_user['broadcaster_id']} - エラー: #{streamer.errors.full_messages.join(', ')}"
            next
          end
        end

        # フォロー関係を保存
        follow_record = Follow.find_or_initialize_by(user_id: id, streamer: streamer)
        if follow_record.new_record?
          follow_record.created_at = Time.current
          follow_record.updated_at = Time.current
          follow_record.save!
          Rails.logger.debug "ユーザー#{user_name}が配信者#{streamer.streamer_name}をフォローしました。"
        else
          Rails.logger.debug "既にフォロー関係が存在します: ユーザー#{user_name} -> 配信者#{streamer.streamer_name}"
        end
      end

      Rails.logger.debug "フォローリストの取り込みが完了しました。"
    end

  private

  # TwitchユーザーIDを取得
  def fetch_twitch_user_id
    response = Faraday.get("https://api.twitch.tv/helix/users") do |req|
      req.params["id"] = [ uid ]  # `uid` を配列として渡す
      req.headers["Authorization"] = "Bearer #{access_token}"
      req.headers["Client-ID"] = ENV["TWITCH_CLIENT_ID"]
    end

    if response.success?
      data = JSON.parse(response.body)["data"]
      if data.any?
        data.first["id"]  # ここでユーザーIDの文字列を返す
      else
        Rails.logger.error "Twitch APIからユーザーデータが返されませんでした。"
        nil
      end
    else
      Rails.logger.error "Twitch APIリクエストが失敗しました。ステータスコード: #{response.code}, メッセージ: #{response.message}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "TwitchユーザーIDの取得中にエラーが発生しました: #{e.message}"
    nil
  end

# フォローリストを取得（ページネーション対応）
def fetch_follow_list(twitch_user_id)
  Rails.logger.debug "フォローしている配信者の取得を開始します。TwitchユーザーID: #{twitch_user_id}"
  followed_channels = []

  # 初期パラメータ設定
  params = {
    user_id: twitch_user_id, # フォローしている配信者を取得するユーザーのID
    first: 100        # 最大100件まで取得可能
  }

  # リクエストヘッダー設定
  headers = {
    "Authorization" => "Bearer #{access_token}",
    "Client-Id" => ENV["TWITCH_CLIENT_ID"],
    "Accept" => "application/json"
  }

  # Faradayの接続設定
  connection = Faraday.new(url: "https://api.twitch.tv") do |conn|
    conn.request :url_encoded       # リクエストボディをURLエンコード
    conn.response :logger           # デバッグ用。不要な場合はコメントアウトしてください。
    conn.adapter Faraday.default_adapter
  end

  loop do
    # APIリクエストの送信
    response = connection.get("/helix/channels/followed") do |req|
      req.params = params
      req.headers = headers
    end

    if response.success?
      begin
        # レスポンスをJSONとしてパース
        data = JSON.parse(response.body)
        Rails.logger.debug "データの中身: #{data.inspect}"
        followed_channels.concat(data["data"])

        # ページネーションのカーソル確認
        pagination = data["pagination"]
        if pagination && pagination["cursor"]
          params[:after] = pagination["cursor"]
          Rails.logger.debug "次のページへ移行します。カーソル: #{pagination['cursor']}"
        else
          Rails.logger.debug "全てのフォロー中の配信者を取得しました。"
          break
        end
      rescue JSON::ParserError => e
        Rails.logger.error "JSONの解析中にエラーが発生しました。レスポンス: #{response.body}, エラー: #{e.message}"
        break
      end
    else
      Rails.logger.error "Twitch APIリクエストが失敗しました。ステータスコード: #{response.status}, メッセージ: #{response.reason_phrase}, レスポンス: #{response.body}"
      break
    end
  end

  Rails.logger.info "取得したフォロー中の配信者数: #{followed_channels.size}"
  Rails.logger.info "フォローリストの取り込みが完了しました。"

  followed_channels
  rescue Faraday::ConnectionFailed => e
    Rails.logger.error "Twitch APIへの接続に失敗しました: #{e.message}"
    nil
  rescue Faraday::TimeoutError => e
    Rails.logger.error "Twitch APIリクエストがタイムアウトしました: #{e.message}"
    nil
  rescue StandardError => e
    Rails.logger.error "フォローリストの取得中に予期せぬエラーが発生しました: #{e.message}"
    nil
  end

  def fetch_streamer_details(broadcaster_id)
    connection = Faraday.new(url: "https://api.twitch.tv") do |conn|
      conn.request :url_encoded
      conn.response :logger # デバッグ用。不要な場合はコメントアウト
      conn.adapter Faraday.default_adapter
    end

    response = connection.get("/helix/users") do |req|
      req.params["id"] = broadcaster_id
      req.headers["Authorization"] = "Bearer #{access_token}"
      req.headers["Client-Id"] = ENV["TWITCH_CLIENT_ID"]
      req.headers["Accept"] = "application/json"
    end

    if response.success?
      data = JSON.parse(response.body)
      data["data"].first # 配列の最初の要素を返す
    else
      Rails.logger.error "配信者詳細情報の取得に失敗しました: #{response.status} - #{response.body}"
      nil
    end
  rescue JSON::ParserError => e
    Rails.logger.error "JSONの解析中にエラーが発生しました: #{e.message}"
    nil
  end
end

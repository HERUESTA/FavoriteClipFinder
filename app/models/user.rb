class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :omniauthable, omniauth_providers: [ :twitch ]

  # uidを元にユーザーを検索または作成し、トークンがない場合や期限が切れている場合は更新
  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize do |u|
      u.user_name = auth.info.name
      u.email = auth.info.email if auth.info.email.present? # Twitchのemailがあれば保存
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
end

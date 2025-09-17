module Api
  class ImportFollows
    def initialize(user)
      @user = user
    end

    def call
      twitch_user_id = fetch_twitch_user_id
      unless twitch_user_id
        Rails.logger.error "TwitchユーザーIDの取得に失敗しました。"
        return
      end

      follows = fetch_follow_list(twitch_user_id)
      unless follows
        Rails.logger.error "フォローリストの取得に失敗しました。"
        return
      end

      follows.each do |followed_user|
        if followed_user["broadcaster_id"].blank?
          Rails.logger.error "不完全なデータをスキップしました: #{followed_user.inspect}"
          next
        end

        user_details = fetch_broadcaster_details(followed_user["broadcaster_id"])

        if user_details.nil?
          Rails.logger.error "配信者情報の取得に失敗しました: #{followed_user['broadcaster_id']}"
          next
        end

        broadcaster = Broadcaster.find_or_initialize_by(broadcaster_id: followed_user["broadcaster_id"])

        if broadcaster.new_record?
          broadcaster.broadcaster_login = user_details["login"]
          broadcaster.broadcaster_name = user_details["display_name"] || user_details["broadcaster_name"]
          broadcaster.profile_image_url = user_details["profile_image_url"]

          if broadcaster.save
            Rails.logger.debug "新しい配信者を登録しました: #{broadcaster.broadcaster_login} (ID: #{broadcaster.broadcaster_id})"
          else
            Rails.logger.error "配信者の登録に失敗しました: #{followed_user['broadcaster_id']} - エラー: #{broadcaster.errors.full_messages.join(', ')}"
            next
          end
        end

        follow_record = Follow.find_or_initialize_by(user_id: @user.id, broadcaster: broadcaster)
        if follow_record.new_record?
          follow_record.created_at = Time.current
          follow_record.updated_at = Time.current
          follow_record.save!
          Rails.logger.debug "ユーザー#{@user.user_name}が配信者#{broadcaster.broadcaster_name}をフォローしました。"
        end
      end

      Rails.logger.debug "フォローリストの取り込みが完了しました。"
    end

    private

    def fetch_twitch_user_id
      response = Faraday.get("https://api.twitch.tv/helix/users") do |req|
        req.params["id"] = [ @user.uid ]
        req.headers["Authorization"] = "Bearer #{@user.access_token}"
        req.headers["Client-ID"] = ENV["TWITCH_CLIENT_ID"]
      end

      if response.success?
        data = JSON.parse(response.body)["data"]
        if data.any?
          data.first["id"]
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

    def fetch_follow_list(twitch_user_id)
      followed_channels = []

      params = {
        user_id: twitch_user_id,
        first: 100
      }

      headers = {
        "Authorization" => "Bearer #{@user.access_token}",
        "Client-Id" => ENV["TWITCH_CLIENT_ID"],
        "Accept" => "application/json"
      }

      loop do
        response = twitch_connection.get("helix/channels/followed") do |req|
          req.params = params
          req.headers = headers
        end

        if response.success?
          begin
            data = JSON.parse(response.body)
            followed_channels.concat(data["data"])
          rescue JSON::ParserError => e
            Rails.logger.error "JSONの解析中にエラーが発生しました。レスポンス: #{response.body}, エラー: #{e.message}"
            break
          end
        else
          Rails.logger.error "Twitch APIリクエストが失敗しました。ステータスコード: #{response.status}, メッセージ: #{response.reason_phrase}, レスポンス: #{response.body}"
          break
        end

        # ページネーション処理を省略するためループを終了
        break
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

    def fetch_broadcaster_details(broadcaster_id)
      response = twitch_connection.get("helix/users") do |req|
        req.params["id"] = broadcaster_id
        req.headers["Authorization"] = "Bearer #{@user.access_token}"
        req.headers["Client-ID"] = ENV["TWITCH_CLIENT_ID"]
      end

      if response.success?
        data = JSON.parse(response.body)
        data["data"].first
      else
        Rails.logger.error "配信者詳細情報の取得に失敗しました: #{response.status} - #{response.body}"
        nil
      end
    rescue JSON::ParserError => e
      Rails.logger.error "JSONの解析中にエラーが発生しました: #{e.message}"
      nil
    end

    def twitch_connection
      @twitch_connection ||= Faraday.new(url: "https://api.twitch.tv") do |conn|
        conn.request :url_encoded
        conn.adapter Faraday.default_adapter
      end
    end
  end
end

class UsersController < ApplicationController
  # TOPページに遷移
  def index
    if current_user.present?
      # token_expires_atがnilでないことを確認してから比較する

      if current_user.token_expires_at.present? && current_user.token_expires_at < Time.now
        refresh_access_token(current_user)
      end

      user_id = current_user.id

      Rails.logger.debug "Current access token: #{current_user.access_token}"
      @followed_channels = fetch_followed_channels(user_id)
      Rails.logger.debug "Followed channels fetched successfully: #{@followed_channels.inspect}"
    else
      @followed_channels = nil
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
    end

    if response.success?
      token_data = JSON.parse(response.body)
      user.update(
        access_token: token_data["access_token"],
        refresh_token: token_data["refresh_token"],
        token_expires_at: Time.now + token_data["expires_in"].to_i.seconds
      )
      Rails.logger.debug "Access token refreshed successfully!"
    else
      Rails.logger.error "Failed to refresh access token: #{response.body}"
      redirect_to root_path, alert: "アクセストークンの更新に失敗しました。"
    end
  end

  # フォローリストを取得するメソッド (Faradayを使用)
  def fetch_followed_channels(user_id)
    client_id = ENV["TWITCH_CLIENT_ID"]
    access_token = current_user.access_token
    Rails.logger.debug "Current access token: #{access_token}"

    begin
      response = Faraday.get("https://api.twitch.tv/helix/channels/followed") do |req|
        req.params["user_id"] = current_user.uid
        req.headers["Authorization"] = "Bearer #{access_token}"
        req.headers["Client-ID"] = client_id
      end

      if response.success?
        follows = JSON.parse(response.body)["data"]
        user_ids = follows.map { |follow| follow["broadcaster_id"] }

        users_info = fetch_users_info(access_token, user_ids)
        follows.map do |follow|
          user_info = users_info.find { |user| user["id"] == follow["broadcaster_id"] }
          {
            "broadcaster_name" => follow["broadcaster_name"],
            "profile_image_url" => user_info ? user_info["profile_image_url"] : nil
          }
        end
      else
        Rails.logger.error "Failed to fetch follows: #{response.body}"
        []
      end
    rescue Faraday::ConnectionFailed => e
      Rails.logger.error "Twitch APIへの接続に失敗しました: #{e.message}"
      flash[:alert] = "Twitch APIへの接続に失敗しました。"
      []
    end
  end

  # ユーザー情報を取得するメソッド
  def fetch_users_info(access_token, user_ids)
    response = Faraday.get("https://api.twitch.tv/helix/users") do |req|
      req.params["id"] = user_ids
      req.headers["Authorization"] = "Bearer #{access_token}"
      req.headers["Client-ID"] = ENV["TWITCH_CLIENT_ID"]
    end

    if response.success?
      JSON.parse(response.body)["data"]
    else
      Rails.logger.error "Failed to fetch users info: #{response.body}"
      []
    end
  end
end

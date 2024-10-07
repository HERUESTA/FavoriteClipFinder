class UsersController < ApplicationController
  def index
    if current_user.present?
      # アクセストークンがnilの場合、リフレッシュトークンを使用して新しいアクセストークンを取得する
      if current_user.access_token.nil?
        Rails.logger.debug "Access token is missing, attempting to refresh using refresh token."
        refresh_access_token(current_user)
      end

      # トークンの有効期限を確認し、必要ならリフレッシュ
      if current_user.token_expires_at.present? && current_user.token_expires_at < Time.now
        refresh_access_token(current_user)
      end

      user_id = current_user.id
      @followed_channels = fetch_followed_channels(user_id)
    else
      @followed_channels = nil
    end
  end

  # アクセストークンをリフレッシュするメソッド
  def refresh_access_token(user)
    # refresh_tokenを使用してTwitch APIから新しいアクセストークンを取得
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
      Rails.logger.debug "New access token: #{token_data["access_token"]}"

      # 新しいアクセストークン、リフレッシュトークン、有効期限を保存
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

  # その他のメソッド（fetch_followed_channelsなど）はここに続く
end
class UsersController < ApplicationController
  def index
    if current_user.present?
      if current_user.refresh_token.blank?
        Rails.logger.debug "リフレッシュトークンが存在しないため、再認証を実施します。"
        redirect_to root_path 
      end

      if current_user.token_expires_at.present? && current_user.token_expires_at < Time.now
        Rails.logger.debug "アクセストークンの有効期限が切れています。再取得を試みます。"
        refresh_access_token(current_user)
      else
        Rails.logger.debug "アクセストークンは有効です。"
      end

      user_id = current_user.id
      @followed_channels = fetch_followed_channels(user_id)
    else
      Rails.logger.debug "ログインしているユーザーがいません。"
      @followed_channels = nil
    end
  end

  def refresh_access_token(user)
    return if user.refresh_token.blank? # リフレッシュトークンがない場合、再認証を要求
    Rails.logger.debug "アクセストークンの再取得を試みます。"

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
      Rails.logger.debug "アクセストークンの再取得に成功しました。"
    else
      Rails.logger.error "アクセストークンの再取得に失敗しました: #{response.body}"
      redirect_to root_path, alert: "再認証が必要です。"
    end
  end
end
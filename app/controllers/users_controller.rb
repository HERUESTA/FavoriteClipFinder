class UsersController < ApplicationController
  after_action :set_followed_channels, only: [ :index ]
  # TOPページに遷移

  def index
    if current_user.present?
      Rails.logger.debug "現在のユーザー: #{current_user}"
      # トークンの期限が存在し、期限が切れている場合はリフレッシュ
      if current_user.token_expires_at.present? && current_user.token_expires_at < Time.now
        refresh_access_token(current_user)
      end
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

  # マイページへ
  def show
  end
end

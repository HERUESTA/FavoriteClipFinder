class UsersController < ApplicationController
  # TOPページに遷移
  def index
    if current_user.present?
      # トークンの有効期限が存在し、期限が切れている場合はリフレッシュ
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
    else
      redirect_to root_path, alert: "アクセストークンの更新に失敗しました。"
    end
  end

  # マイページへ
  def show
    # プレイリストを取得
    @playlists = current_user.playlists
  end
end

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_followed_channnels

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  # フォローリストを取得するメソッド
  def set_followed_channnels
    if user_signed_in?
      @followed_channels = fetch_followed_channels(current_user.id)
    else
      @followed_channels = []
    end
  end

  # フォローリストをAPI経由で取得
  # フォローリストを取得するメソッド (Faradayを使用)
  def fetch_followed_channels(user_id)
    client_id = ENV["TWITCH_CLIENT_ID"]
    access_token = current_user.access_token

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
        []
      end
    rescue Faraday::ConnectionFailed => e
      []
    end
  end

  # ユーザー情報を取得するメソッド
  def fetch_users_info(access_token, user_ids)
    # Twitch APIドキュメントに基づき、'id' または 'login' のどちらかを使用
    response = Faraday.get("https://api.twitch.tv/helix/users") do |req|
      req.params["id"] = user_ids  # 正しく渡すため、カンマ区切りでなく配列として渡す
      req.headers["Authorization"] = "Bearer #{access_token}"
      req.headers["Client-ID"] = ENV["TWITCH_CLIENT_ID"]
    end

    if response.success?
      JSON.parse(response.body)["data"]
    else
      []
    end
  end
end

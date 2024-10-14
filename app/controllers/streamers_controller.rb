class StreamersController < ApplicationController
  def show
    streamer_name = params[:name]
    streamer_id = get_streamer_id(streamer_name)

    if streamer_id
      clips = fetch_clips(streamer_id)

      if clips.any?
        @clips = clips
        respond_to do |format|
          format.html # show.html.erbを通常通りレンダリング
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace("main-content", partial: "streamers/clips", locals: { clips: @clips })
          end
        end
      else
        render turbo_stream: turbo_stream.replace("main-content", partial: "streamers/clips", locals: { clips: [] })
      end
    else
      render turbo_stream: turbo_stream.replace("main-content", partial: "streamers/clips", locals: { clips: [] })
    end
  end

  private

  # 配信者IDを取得するメソッド
  def get_streamer_id(streamer_name)
    # Twitch APIから配信者IDを取得するロジック
    access_token = ENV["TWITCH_ACCESS_TOKEN"]
    response = send_twitch_request("users", { login: streamer_name }, access_token)
    return unless response.success?

    user_data = JSON.parse(response.body)
    user_data["data"].first["id"] if user_data["data"].any?
  end

  private

  # 配信者のユーザーIDを取得する
  def get_streamer_id(streamer_name)
    access_token = ENV["TWITCH_ACCESS_TOKEN"]
    response = send_twitch_request("users", { login: streamer_name }, access_token)
    return unless response.success?

    user_data = JSON.parse(response.body)
    user_data["data"].first["id"] if user_data["data"].any?
  end

  # クリップを取得する
  def fetch_clips(streamer_id)
    access_token = ENV["TWITCH_ACCESS_TOKEN"]
    response = send_twitch_request("clips", { broadcaster_id: streamer_id }, access_token)
    return [] unless response.success?

    clips = JSON.parse(response.body)["data"]
    clips.select { |clip| clip["language"] == "ja" }
  end

  # Twitch APIへのリクエスト送信
  def send_twitch_request(endpoint, params, access_token)
    Faraday.get("https://api.twitch.tv/helix/#{endpoint}") do |req|
      req.params = params
      req.headers["Authorization"] = "Bearer #{access_token}"
      req.headers["Client-ID"] = ENV["TWITCH_CLIENT_ID"]
      req.options.timeout = 10  # タイムアウト設定 (秒)
      req.options.open_timeout = 10  # 接続時のタイムアウト (秒)
    end
  end
end

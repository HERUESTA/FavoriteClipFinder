class StreamersController < ApplicationController
  def show
    streamer_name = params[:name]
    streamer_info = get_streamer_info(streamer_name)

    if streamer_info
      clips = fetch_clips(streamer_info[:id])

      if clips.any?
        @clips = clips
        @streamer_profile_image = streamer_info[:profile_image_url] # 配信者のプロフィール画像
        respond_to do |format|
          format.html do
            render partial: "streamers/clips", locals: { clips: @clips, streamer_profile_image: @streamer_profile_image, error_message: nil }
          end
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace("main-content", partial: "streamers/clips", locals: { clips: @clips, streamer_profile_image: @streamer_profile_image, error_message: nil })
          end
        end
      else
        respond_to do |format|
          format.html do
            render partial: "streamers/clips", locals: { clips: [], }
          end
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace("main-content", partial: "streamers/clips", locals: { clips: []})
          end
        end
      end
    else
      respond_to do |format|
        format.html do
          render partial: "streamers/clips", locals: { clips: [], error_message:  }
        end
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("main-content", partial: "streamers/clips", locals: { clips: [], error_message:  })
        end
      end
    end
  end

  private

  # 配信者IDとプロフィール画像を取得するメソッド
  def get_streamer_info(streamer_name)
    access_token = ENV["TWITCH_ACCESS_TOKEN"]
    response = send_twitch_request("users", { login: streamer_name }, access_token)

    return unless response.success?

    user_data = JSON.parse(response.body)

    if user_data["data"].any?
      {
        id: user_data["data"].first["id"],
        profile_image_url: user_data["data"].first["profile_image_url"] # プロフィール画像のURLを取得
      }
    else
      nil
    end
  end

  # クリップを取得する
  def fetch_clips(streamer_id)
    access_token = ENV["TWITCH_ACCESS_TOKEN"]
    response = send_twitch_request("clips", { broadcaster_id: streamer_id }, access_token)

    return [] unless response.success?

    clips = JSON.parse(response.body)["data"]

    # プロフィール画像を含めるために配信者の情報を取得
    streamer_info = get_streamer_info_by_id(streamer_id)

    clips.select do |clip|
      clip["language"] == "ja"
    end.map do |clip|
      game_name = fetch_game_name(clip["game_id"]) # ゲーム名を取得
      # 配信者のプロフィール画像を追加
      clip.merge("game_name" => game_name, "broadcaster_profile_image" => streamer_info[:profile_image_url])
    end
  end

  # IDで配信者情報を取得するメソッド
  def get_streamer_info_by_id(streamer_id)
    access_token = ENV["TWITCH_ACCESS_TOKEN"]
    response = send_twitch_request("users", { id: streamer_id }, access_token)

    return nil unless response.success?

    user_data = JSON.parse(response.body)
    if user_data["data"].any?
      {
        profile_image_url: user_data["data"].first["profile_image_url"]
      }
    else
      nil
    end
  end

  # ゲームの名前を取得
  def fetch_game_name(game_id)
    access_token = ENV["TWITCH_ACCESS_TOKEN"]
    response = send_twitch_request("games", { id: game_id }, access_token)

    return nil unless response.success?

    game_data = JSON.parse(response.body)
    game_data["data"].first["name"] if game_data["data"].any? # ゲーム名を取得
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

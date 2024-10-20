class StreamersController < ApplicationController
  # 配信者のクリップを表示するアクション
  def show
    streamer_name = params[:name] # params[:name]を使用

    # params[:name]が数値かどうかを判定し、数値ならそのままIDとして使用
    if numeric?(streamer_name)
      @streamer_info = { id: streamer_name, profile_image_url: fetch_profile_image(streamer_name) }
    else
      @streamer_info = get_streamer_info(streamer_name) # 名前をIDに変換
    end

    if @streamer_info
      cursor = params[:cursor] # ページネーション用のカーソル
      clips, pagination = fetch_clips(@streamer_info[:id], cursor)

      if clips.any?
        @next_cursor = pagination["cursor"] # 次のページのカーソル

        # @clips に対して配列ベースのページネーションを設定
        @clips = Kaminari.paginate_array(clips).page(params[:page]).per(12) # 1ページに12個のクリップを表示
        @total_pages = @clips.total_pages

        # @next_cursor の内容をログに出力して確認
        Rails.logger.debug "Next Cursor: #{@next_cursor.inspect}"

        respond_to do |format|
          format.html # HTMLリクエストの場合、ビューを通常通りレンダリング
          format.turbo_stream do # Turbo Streamリクエストの場合、部分的に更新
            render turbo_stream: turbo_stream.append("clips", partial: "streamers/clips", locals: { clips: @clips, next_cursor: @next_cursor })
          end
        end
      else
        render_no_clips(streamer_name)
      end
    else
      render_no_clips(streamer_name)
    end
  end

  private

  # 配信者のプロフィール画像を取得するメソッド
  def fetch_profile_image(streamer_id)
    access_token = ENV["TWITCH_ACCESS_TOKEN"]
    response = send_twitch_request("users", { id: streamer_id }, access_token)

    return unless response.success?

    user_data = JSON.parse(response.body)
    if user_data["data"].any?
      user_data["data"].first["profile_image_url"]
    else
      nil
    end
  end

  # 配信者情報を取得するメソッド（名前からIDに変換）
  def get_streamer_info(streamer_name)
    access_token = ENV["TWITCH_ACCESS_TOKEN"]
    response = send_twitch_request("users", { login: streamer_name }, access_token)

    return unless response.success?

    user_data = JSON.parse(response.body)
    if user_data["data"].any?
      {
        id: user_data["data"].first["id"],
        profile_image_url: user_data["data"].first["profile_image_url"]
      }
    else
      nil
    end
  end

  # 配信者IDでクリップを取得するメソッド（ページネーション対応）
  def fetch_clips(streamer_id, cursor = nil)
    access_token = ENV["TWITCH_ACCESS_TOKEN"]
    params = {
      broadcaster_id: streamer_id,
      first: 60, # 一度に取得するクリップ数
      after: cursor # 次のページのカーソル
    }.compact

    response = send_twitch_request("clips", params, access_token)
    return [ [], {} ] unless response.success?

    data = JSON.parse(response.body)
    clips = data["data"]
    pagination = data["pagination"]

    # 日本語のクリップのみをフィルタリング
    clips.select! { |clip| clip["language"] == "ja" }

    # ゲームIDの一覧を取得
    game_ids = clips.map { |clip| clip["game_id"] }.uniq
    # ゲーム名を一括で取得
    game_names = fetch_game_names(game_ids)

    # 各クリップにゲーム名と配信者のプロフィール画像を追加
    clips.each do |clip|
      clip["game_name"] = game_names[clip["game_id"]]
      clip["broadcaster_profile_image"] = @streamer_info[:profile_image_url]
    end

    [ clips, pagination ]
  end

  # 複数のゲームIDからゲーム名を取得するメソッド
  def fetch_game_names(game_ids)
    return {} if game_ids.empty?

    access_token = ENV["TWITCH_ACCESS_TOKEN"]
    game_names = {}

    # Twitch APIは一度に最大100件のIDを受け取れる
    game_ids.each_slice(100) do |ids|
      response = send_twitch_request("games", { id: ids }, access_token)
      next unless response.success?

      data = JSON.parse(response.body)
      data["data"].each do |game|
        game_names[game["id"]] = game["name"]
      end
    end

    game_names
  end

  # APIリクエストを送信する汎用メソッド
  def send_twitch_request(endpoint, params, access_token)
    Faraday.get("https://api.twitch.tv/helix/#{endpoint}") do |req|
      req.params = params
      req.headers["Authorization"] = "Bearer #{access_token}"
      req.headers["Client-ID"] = ENV["TWITCH_CLIENT_ID"]
      req.options.timeout = 10
      req.options.open_timeout = 10
    end
  end

  # 数値かどうかを判定するヘルパーメソッド
  def numeric?(string)
    string.match?(/\A\d+\z/)
  end

  # クリップが見つからない場合のレスポンスを統一
  def render_no_clips(streamer_name)
    respond_to do |format|
      format.html do
        render partial: "streamers/clips", locals: { clips: [], streamer_name: streamer_name, next_cursor: nil }
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("clips", partial: "streamers/clips", locals: { clips: [], streamer_name: streamer_name, next_cursor: nil })
      end
    end
  end
end

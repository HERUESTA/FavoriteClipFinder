class GamesController < ApplicationController
  # ゲームIDを使ってクリップを表示するアクション
  def show
    game_name = params[:name]
    Rails.logger.info "Game Name received: #{game_name}"

    # params[:name]が数値かどうかを判定し、数値ならそのままIDとして使用
    game_id = if numeric?(game_name)
                Rails.logger.info "Game Name is numeric, using it as ID directly"
                game_name
    else
                Rails.logger.info "Game Name is not numeric, calling get_game_info"
                game_info = get_game_info(game_name)
                game_info ? game_info[:id] : nil
    end

    if game_id
      # ゲームIDからボックスアートURLを取得
      box_art_url = fetch_game_box_art(game_id)
      @game_info = { id: game_id, box_art_url: box_art_url }

      Rails.logger.info "Game Info: #{@game_info.inspect}"

      cursor = params[:cursor] # ページネーション用のカーソル
      clips, pagination = fetch_clips(@game_info[:id], cursor)

      if clips.any?
        @next_cursor = pagination["cursor"]

        @clips = Kaminari.paginate_array(clips).page(params[:page]).per(12)
        @total_pages = @clips.total_pages

        respond_to do |format|
          format.html
          format.turbo_stream do
            render turbo_stream: turbo_stream.append("clips", partial: "games/clips", locals: { clips: @clips, next_cursor: @next_cursor })
          end
        end
      else
        render_no_clips(game_name)
      end
    else
      Rails.logger.info "No game info found for #{game_name}"
      render_no_clips(game_name)
    end
  end

  private

  # ゲームのボックスアート（アイコン）を取得するメソッド
  def fetch_game_box_art(game_id)
    Rails.logger.info "fetch_game_box_art called with Game ID: #{game_id}"

    access_token = ENV["TWITCH_ACCESS_TOKEN"]
    response = send_twitch_request("games", { id: game_id }, access_token)

    return unless response.success?

    game_data = JSON.parse(response.body)

    if game_data["data"].any?
      box_art_url = game_data["data"].first["box_art_url"]
      Rails.logger.info "Box Art URL before replace: #{box_art_url}"

      # プレースホルダーを置き換え
      box_art_url = box_art_url.gsub("{width}", "150").gsub("{height}", "200")

      Rails.logger.info "Box Art URL after replace: #{box_art_url}"
      box_art_url
    else
      Rails.logger.info "No game data found for Game ID: #{game_id}"
      nil
    end
  end

  # ゲーム情報を取得するメソッド（名前からIDに変換）
  def get_game_info(game_name)
    Rails.logger.info "get_game_info called with Game Name: #{game_name}"

    access_token = ENV["TWITCH_ACCESS_TOKEN"]
    response = send_twitch_request("games", { name: game_name }, access_token)

    return unless response.success?

    game_data = JSON.parse(response.body)
    if game_data["data"].any?
      {
        id: game_data["data"].first["id"],
        box_art_url: game_data["data"].first["box_art_url"]
      }
    else
      Rails.logger.info "No game data found for Game Name: #{game_name}"
      nil
    end
  end

  # ゲームIDでクリップを取得するメソッド（ページネーション対応）
  def fetch_clips(game_id, cursor = nil)
    access_token = ENV["TWITCH_ACCESS_TOKEN"]
    params = {
      game_id: game_id,
      first: 80, # 一度に取得するクリップ数
      after: cursor # 次のページのカーソル
    }.compact

    response = send_twitch_request("clips", params, access_token)
    return [ [], {} ] unless response.success?

    data = JSON.parse(response.body)
    clips = data["data"]
    pagination = data["pagination"]

    # 日本語のクリップのみをフィルタリング
    clips.select! { |clip| clip["language"] == "ja" }

    # 配信者IDの一覧を取得
    broadcaster_ids = clips.map { |clip| clip["broadcaster_id"] }.uniq

    # 配信者情報（アイコン、名前）を一括で取得
    broadcaster_info = fetch_broadcaster_info(broadcaster_ids)

    # 各クリップに配信者の名前とプロフィール画像を追加
    clips.each do |clip|
      clip["broadcaster_name"] = broadcaster_info[clip["broadcaster_id"]][:name]
      clip["broadcaster_profile_image"] = broadcaster_info[clip["broadcaster_id"]][:profile_image_url]
    end

    [ clips, pagination ]
  end

  # 複数の配信者IDから名前とアイコンを取得するメソッド
  def fetch_broadcaster_info(broadcaster_ids)
    return {} if broadcaster_ids.empty?

    access_token = ENV["TWITCH_ACCESS_TOKEN"]
    broadcaster_info = {}

    # Twitch APIは一度に最大100件のIDを受け取れる
    broadcaster_ids.each_slice(100) do |ids|
      response = send_twitch_request("users", { id: ids }, access_token)
      next unless response.success?

      data = JSON.parse(response.body)
      data["data"].each do |broadcaster|
        broadcaster_info[broadcaster["id"]] = {
          name: broadcaster["display_name"],
          profile_image_url: broadcaster["profile_image_url"]
        }
      end
    end

    broadcaster_info
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
  def render_no_clips(game_name)
    respond_to do |format|
      format.html do
        render partial: "games/clips", locals: { clips: [], game_name: game_name, next_cursor: nil }
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("clips", partial: "games/clips", locals: { clips: [], game_name: game_name, next_cursor: nil })
      end
    end
  end
end

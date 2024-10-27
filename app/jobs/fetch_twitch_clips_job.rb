# app/jobs/fetch_twitch_clips_job.rb

class FetchTwitchClipsJob < ApplicationJob
  queue_as :default

  require "faraday"
  require "json"

  def perform(*args)
    client = Faraday.new(url: "https://api.twitch.tv/helix") do |faraday|
      faraday.request :url_encoded
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter Faraday.default_adapter
    end

    # Twitch APIエンドポイントとパラメータの設定
    response = client.get("/clips", {
      broadcaster_id: fetch_broadcaster_ids, # ストリーマーIDのリスト
      first: 100 # 一度に取得するクリップ数（最大100）
    }) do |req|
      req.headers["Client-ID"] = Rails.application.credentials.twitch[:client_id]
      req.headers["Authorization"] = "Bearer #{Rails.application.credentials.twitch[:access_token]}"
    end

    if response.success?
      clips_data = response.body["data"]
      clips_data.each do |clip|
        Clip.find_or_create_by!(clip_id: clip["id"]) do |c|
          c.streamer_id = fetch_streamer_id(clip["broadcaster_id"])
          c.game_id = fetch_game_id(clip["game_id"])
          c.language = clip["language"]
          c.title = clip["title"]
          c.clip_created_at = clip["created_at"]
          c.thumbnail_url = clip["thumbnail_url"]
          c.duration = clip["duration"].to_i
          c.view_count = clip["view_count"]
        end
      end
    else
      Rails.logger.error "Twitch API Request Failed: #{response.status} - #{response.body}"
    end
  rescue StandardError => e
    Rails.logger.error "Error fetching Twitch clips: #{e.message}"
    # 必要に応じて通知を送る（例: Slack通知）
  end

  private

  # ストリーマーIDのリストを取得または定義するメソッド
  def fetch_broadcaster_ids
    # 例: 特定のストリーマーのIDをデータベースから取得
    Streamer.pluck(:streamer_id)
  end

  # broadcaster_idからstreamerの内部IDを取得するメソッド
  def fetch_streamer_id(broadcaster_id)
    streamer = Streamer.find_by(streamer_id: broadcaster_id)
    streamer&.id
  end

  # game_idからゲームの内部IDを取得するメソッド
  def fetch_game_id(game_id)
    game = Game.find_by(game_id: game_id)
    game&.id
  end
end

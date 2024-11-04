class FetchTwitchClipsJob < ApplicationJob
  queue_as :default

  def perform
    streamer_twitch_ids = Streamer.pluck(:streamer_id)
    twitch_client = TwitchClient.new
    game_cache = {}

    streamer_twitch_ids.each do |streamer_twitch_id|
      # 配信者の詳細情報を取得して更新
      streamer_info = twitch_client.fetch_streamer_info(streamer_twitch_id)
      next unless streamer_info

      streamer = Streamer.find_by(streamer_id: streamer_twitch_id)
      unless streamer
        Rails.logger.error "Streamer with streamer_id #{streamer_twitch_id} not found."
        next
      end

      updated = streamer.update(
        profile_image_url: streamer_info["profile_image_url"],
        display_name: streamer_info["display_name"] || streamer.display_name
      )
      Rails.logger.error("Failed to update Streamer #{streamer_twitch_id}: #{streamer.errors.full_messages.join(', ')}") unless updated

      # クリップを取得
      clips = twitch_client.fetch_clips(streamer_twitch_id, max_results: 50)
      Rails.logger.debug "Number of clips fetched for streamer #{streamer_twitch_id}: #{clips.size}"

      clips.each do |clip_data|
        next unless clip_data.is_a?(Hash)

        # ゲームのキャッシュを利用
        game = game_cache[clip_data["game_id"]]
        unless game
          game = Game.find_by(game_id: clip_data["game_id"])
          if game.nil? && clip_data["game_id"].present?
            game_data = twitch_client.fetch_game(clip_data["game_id"])
            if game_data
              game = Game.create(
                game_id: game_data["id"],
                name: game_data["name"],
                box_art_url: game_data["box_art_url"]
              )
              game_cache[clip_data["game_id"]] = game
              Rails.logger.debug "Created and cached Game: #{game.inspect}"
            else
              Rails.logger.error "Failed to fetch or create Game with ID #{clip_data['game_id']}"
            end
          end
        end

        # Clip レコードを初期化または取得
        clip = Clip.find_or_initialize_by(clip_id: clip_data["id"])
        clip.attributes = {
          streamer_id: streamer.id,
          game_id: game&.id,
          title: clip_data["title"],
          language: clip_data["language"],
          clip_created_at: clip_data["created_at"],
          thumbnail_url: clip_data["thumbnail_url"],
          duration: clip_data["duration"],
          view_count: clip_data["view_count"],
          creator_name: clip_data["creator_name"] || "Unknown"
        }

        # クリップ作成者名が clip_data に含まれていない場合、追加で取得
        if clip_data["creator_name"].blank? && clip_data["creator_id"].present?
          creator_info = twitch_client.fetch_user_info(clip_data["creator_id"])
          clip.creator_name = creator_info&.dig("display_name") || "Unknown"
        end

        # Clip を保存
        unless clip.save
          Rails.logger.error "Error saving clip ID #{clip.clip_id}: #{clip.errors.full_messages.join(', ')}"
        else
          Rails.logger.debug "Successfully saved clip ID #{clip.clip_id}"
        end
      end

      # メモリを解放するために clips を明示的に破棄
      clips = nil
    end
  rescue StandardError => e
    Rails.logger.error "FetchTwitchClipsJob Error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end
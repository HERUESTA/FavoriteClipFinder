class FetchTwitchClipsJob < ApplicationJob
  queue_as :default

  def perform
    streamer_twitch_ids = Streamer.pluck(:streamer_id)
    twitch_client = TwitchClient.new

    streamer_twitch_ids.each do |streamer_twitch_id|
      # 1. 配信者の詳細情報を取得して更新（profile_image_url や display_name など）
      streamer_info = twitch_client.fetch_streamer_info(streamer_twitch_id)

      if streamer_info
        streamer = Streamer.find_by(streamer_id: streamer_twitch_id)
        if streamer
          updated = streamer.update(
            profile_image_url: streamer_info["profile_image_url"],
            display_name: streamer_info["display_name"] || streamer.display_name
          )
          unless updated
            Rails.logger.error "Failed to update Streamer #{streamer_twitch_id}: #{streamer.errors.full_messages.join(', ')}"
          else
            Rails.logger.debug "Successfully updated Streamer #{streamer_twitch_id} with profile_image_url and display_name."
          end
        else
          Rails.logger.error "Streamer with streamer_id #{streamer_twitch_id} not found."
          next
        end
      else
        Rails.logger.error "Failed to fetch streamer info for #{streamer_twitch_id}."
        next
      end

      # 2. クリップを取得
      clips = twitch_client.fetch_clips(streamer_id, max_results: 100)

      Rails.logger.debug "Streamer Twitch ID: #{streamer_twitch_id}"
      Rails.logger.debug "Number of clips fetched: #{clips.size}"
      Rails.logger.debug "Clips class: #{clips.class}"
      Rails.logger.debug "Clips content: #{clips.inspect}"

      clips.each do |clip_data|
        Rails.logger.debug "clip_data class: #{clip_data.class}"
        Rails.logger.debug "clip_data content: #{clip_data.inspect}"

        if clip_data.is_a?(Hash)
          # Streamer レコードを取得
          streamer = Streamer.find_by(streamer_id: streamer_id)
          unless streamer
            Rails.logger.error "Streamer with streamer_id #{streamer_twitch_id} not found."
            next
          end

          # Game レコードを取得
          game = Game.find_by(game_id: clip_data["game_id"])

          # Game レコードが存在しない場合は作成
          if game.nil? && clip_data["game_id"].present?
            game_data = twitch_client.fetch_game(clip_data["game_id"])
            if game_data
              game = Game.create(
                game_id: game_data["id"],
                name: game_data["name"],
                box_art_url: game_data["box_art_url"]
              )
              Rails.logger.debug "Created Game: #{game.inspect}"
            else
              Rails.logger.error "Failed to fetch or create Game with ID #{clip_data['game_id']}"
            end
          end

          # Clip レコードを初期化または取得
          clip = Clip.find_or_initialize_by(clip_id: clip_data["id"])

          # Clip の属性を設定
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
            if creator_info && creator_info["display_name"].present?
              clip.creator_name = creator_info["display_name"]
            else
              clip.creator_name = "Unknown"
            end
          end

          # Clip を保存
          unless clip.save
            Rails.logger.error "Error saving clip ID #{clip.clip_id}: #{clip.errors.full_messages.join(', ')}"
          else
            Rails.logger.debug "Successfully saved clip ID #{clip.clip_id}"
          end
        else
          Rails.logger.error "Unexpected clip_data type: #{clip_data.class}, content: #{clip_data.inspect}"
        end
      end
    end
  rescue StandardError => e
    Rails.logger.error "FetchTwitchClipsJob Error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end

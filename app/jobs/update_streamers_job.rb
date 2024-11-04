class UpdateStreamersJob < ApplicationJob
  queue_as :default

  def perform
    twitch_client = TwitchClient.new
    saved_streamers_count = 0
    cursor = nil

    # 配信者が20人貯まるまでループ
    loop do
      streamers, cursor = twitch_client.fetch_popular_japanese_streamers(limit: 20, cursor: cursor) # ここも20に変更
      break if streamers.blank?

      streamers.each do |streamer_data|
        # 必須フィールドをチェック
        if streamer_data["user_name"].blank? || streamer_data["display_name"].blank? || streamer_data["profile_image_url"].blank?
          Rails.logger.error "Streamer data missing required fields: #{streamer_data.inspect}"
          next
        end

        # Streamer の保存または更新
        streamer = Streamer.find_or_initialize_by(streamer_id: streamer_data["id"])
        streamer.assign_attributes(
          streamer_name: streamer_data["user_name"],
          display_name: streamer_data["display_name"],
          profile_image_url: streamer_data["profile_image_url"]
        )

        if streamer.save
          Rails.logger.info "Successfully saved/updated Streamer #{streamer.streamer_name} (ID: #{streamer.streamer_id})"
          saved_streamers_count += 1
        else
          Rails.logger.error "Failed to save/update Streamer #{streamer.streamer_id}: #{streamer.errors.full_messages.join(', ')}"
        end

        break if saved_streamers_count >= 20
      end
      break if saved_streamers_count >= 20 || cursor.nil? # 20人達成、もしくはページネーションが終了した場合はループを抜ける
    end
  rescue StandardError => e
    Rails.logger.error "UpdateStreamersJob Error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end
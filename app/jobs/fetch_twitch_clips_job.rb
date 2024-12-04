class FetchTwitchClipsJob < ApplicationJob
  queue_as :default

  def perform
    client = TwitchClient.new

    Streamer.order(:id).find_each(batch_size: 500) do |streamer|
      begin
        Rails.logger.info "開始: 配信者 #{streamer.display_name} (ID: #{streamer.streamer_id})"
        clips = get_clips(client, streamer)
        save_clips(clips, streamer)
        Rails.logger.info "終了: 配信者 #{streamer.display_name} (ID: #{streamer.streamer_id})"
      rescue StandardError => e
        Rails.logger.error "エラー: 配信者 #{streamer.display_name} (ID: #{streamer.streamer_id}) - #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
      ensure
        GC.start
      end
    end
  end

  private

  def get_clips(client, streamer)
    client.fetch_clips(streamer.streamer_id, max_results: 120)
  end

  def save_clips(clips, streamer)
    Clip.transaction do
      clips.each do |clip_data|
        save_clip(clip_data, streamer)
      end
    end
  rescue StandardError => e
    Rails.logger.error "クリップ保存中のエラー: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def save_clip(clip_data, streamer)
    Rails.logger.debug "保存するクリップ: #{clip_data}"
    Rails.logger.debug "保存する配信者ID: #{streamer.streamer_id}"

    game = Game.find_or_create_by(game_id: clip_data["game_id"]) do |g|
      game_data = client.fetch_game(clip_data["game_id"])
      if game_data
        g.name = game_data["name"]
        g.box_art_url = game_data["box_art_url"]
      else
        Rails.logger.error "ゲームデータ取得失敗: #{clip_data['game_id']}"
      end
    end

    return unless game

    clip = Clip.find_or_initialize_by(clip_id: clip_data["id"])
    clip.assign_attributes(
      streamer_id: streamer.streamer_id,
      game_id: game.game_id,
      title: clip_data["title"],
      language: clip_data["language"],
      creator_name: clip_data["creator_name"],
      clip_created_at: clip_data["created_at"],
      thumbnail_url: clip_data["thumbnail_url"],
      duration: clip_data["duration"].to_i,
      view_count: clip_data["view_count"].to_i
    )

    if clip.save
      Rails.logger.debug "クリップが正常に保存されました: #{clip.inspect}"
    else
      Rails.logger.error "クリップ保存失敗: #{clip_data['id']} - #{clip.errors.full_messages.join(', ')}"
    end
  rescue StandardError => e
    Rails.logger.error "クリップ保存中のエラー: #{clip_data['id']} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end

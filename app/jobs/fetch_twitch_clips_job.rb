class FetchTwitchClipsJob < ApplicationJob
  queue_as :default

  def perform
    Streamer.order(:id).find_each(batch_size: 500) do |streamer|
      get_clips(streamer)
    end
  end

  private

  def get_clips(streamer)
    @client = TwitchClient.new
    # クリップを取得
    clips = @client.fetch_clips(streamer.streamer_id, 200)

    # クリップを保存
    save_clips(clips, streamer)
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
    game = Game.find_or_create_by(game_id: clip_data["game_id"]) do |g|
      game_data = @client.fetch_game(clip_data["game_id"])
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
  end
end

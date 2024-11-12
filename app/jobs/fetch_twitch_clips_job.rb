class FetchTwitchClipsJob < ApplicationJob
  queue_as :default

  # クリップを保存するメソッド
  def perform
    client = TwitchClient.new
    # すべてのストリーマーのstreamer_idを取得し、クリップを保存する処理を呼び出す
    Streamer.order(:id).find_each do |streamer|
      get_clips(client, streamer)
    end
  end

  private

  # 取得した配信者のクリップをAPIを用いて取得し、保存する
  def get_clips(client, streamer)

    # クリップを取得（最大20件）
    clips = client.fetch_clips(streamer.streamer_id, max_results: 20)

    # 各クリップをデータベースに保存
    clips.each do |clip_data|
      save_clip(client, clip_data, streamer)
    end
  end

  # クリップをデータベースに保存する
  def save_clip(client, clip_data, streamer)
    Rails.logger.debug "保存しようとしているクリップのデータ: #{clip_data}"
    Rails.logger.debug "保存しようとしている配信者ID: #{streamer&.streamer_id}"
    Rails.logger.debug "保存しようとしているゲームID: #{clip_data['game_id']}"

    game = Game.find_by(game_id: clip_data["game_id"])

    unless game
      # データベースに存在するゲームIDではない場合、fetch_gameを呼び出す
      game_data = client.fetch_game(clip_data["game_id"])
      if game_data
        game = Game.create(
          game_id: game_data["id"],
          name: game_data["name"],
          box_art_url: game_data["box_art_url"]
        )
        Rails.logger.debug "新しいゲームが保存されました: #{game.inspect}"
      else
        Rails.logger.error "Failed to fetch and save game with ID #{clip_data['game_id']}"
        return # ゲームが取得できなければクリップの保存を中止
      end
    end

    Rails.logger.debug "使用するstreamer_id: #{streamer.streamer_id}, 使用するgame_id: #{game.game_id}"

    clip = Clip.find_or_initialize_by(clip_id: clip_data["id"])
    clip.attributes = {
      clip_id: clip_data["id"],
      streamer_id: streamer.streamer_id,
      game_id: game.game_id,
      title: clip_data["title"],
      language: clip_data["language"],
      creator_name: clip_data["creator_name"],
      clip_created_at: clip_data["created_at"],
      thumbnail_url: clip_data["thumbnail_url"],
      duration: clip_data["duration"].to_i,
      view_count: clip_data["view_count"].to_i
    }

    if clip.save
      Rails.logger.debug "クリップが正常に保存されました: #{clip.inspect}"
    else
      Rails.logger.error "Failed to save clip ID #{clip_data['id']}: #{clip.errors.full_messages.join(', ')}"
    end
  rescue StandardError => e
    Rails.logger.error "Failed to save clip ID #{clip_data['id']}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end

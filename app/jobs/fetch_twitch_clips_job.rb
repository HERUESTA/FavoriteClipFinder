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

  # ゲームの存在確認と取得
  game = Game.find_by(game_id: clip_data["game_id"])
  unless game
    # ゲームがデータベースに存在しない場合、fetch_gameを呼び出して取得
    game_data = client.fetch_game(clip_data["game_id"])
    if game_data
      game = Game.create(
        game_id: game_data["id"],
        name: game_data["name"],
        box_art_url: game_data["box_art_url"]
      )
      Rails.logger.debug "新しいゲームが保存されました: #{game.inspect}"
    else
      # ゲームデータの取得失敗時の処理
      Rails.logger.error "Failed to fetch and save game with ID #{clip_data['game_id']}"
      return # ゲームが取得できなければクリップの保存を中止
    end
  end

  # Clip の作成または更新
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

  # デバッグ情報を追加して Clip の状態を確認
  Rails.logger.debug "Clip before save: #{clip.inspect}"
  Rails.logger.debug "Clip streamer association: #{clip.streamer.inspect}"
  Rails.logger.debug "Clip game association: #{clip.game.inspect}"

  # Clip の保存処理
  if clip.save
    Rails.logger.debug "クリップが正常に保存されました: #{clip.inspect}"
  else
    # 保存に失敗した場合のエラーログ
    Rails.logger.error "Failed to save clip ID #{clip_data['id']}: #{clip.errors.full_messages.join(', ')}"
  end

# 例外発生時のエラーハンドリング
rescue StandardError => e
  Rails.logger.error "Failed to save clip ID #{clip_data['id']}: #{e.message}"
  Rails.logger.error e.backtrace.join("\n")
end
end

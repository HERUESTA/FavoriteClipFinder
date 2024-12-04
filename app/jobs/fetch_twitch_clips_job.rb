class FetchTwitchClipsJob < ApplicationJob
  queue_as :default

  # クリップを保存するメソッド
  def perform
    client = TwitchClient.new

    # 配信者を順に処理
    Streamer.order(:id).find_each do |streamer|
      begin
        Rails.logger.info "開始: 配信者 #{streamer.display_name} (ID: #{streamer.streamer_id})"
        get_clips(client, streamer)
        Rails.logger.info "終了: 配信者 #{streamer.display_name} (ID: #{streamer.streamer_id})"
      rescue StandardError => e
        Rails.logger.error "エラー: 配信者 #{streamer.display_name} (ID: #{streamer.streamer_id}) - #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
      end
    end
  end

  private

  # 取得した配信者のクリップをAPIを用いて取得し、保存する
  def get_clips(client, streamer)
    # 最大120件のクリップを取得
    clips = client.fetch_clips(streamer.streamer_id, max_results: 120)

    # 各クリップをデータベースに保存
    clips.each do |clip_data|
      save_clip(client, clip_data, streamer)
    end
  end

  # クリップをデータベースに保存する
  def save_clip(client, clip_data, streamer)
    Rails.logger.debug "保存するクリップ: #{clip_data}"
    Rails.logger.debug "保存する配信者ID: #{streamer.streamer_id}"

    # トランザクションを使用してクリップとゲームデータを保存
    Clip.transaction do
      # ゲームデータの確認または取得
      game = Game.find_by(game_id: clip_data["game_id"])
      unless game
        game_data = client.fetch_game(clip_data["game_id"])
        if game_data
          game = Game.create!(
            game_id: game_data["id"],
            name: game_data["name"],
            box_art_url: game_data["box_art_url"]
          )
          Rails.logger.debug "新しいゲームが保存されました: #{game.inspect}"
        else
          Rails.logger.error "ゲームデータ取得失敗: #{clip_data['game_id']}"
          return # ゲームデータが取得できなければクリップ保存を中止
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

      if clip.save
        Rails.logger.debug "クリップが正常に保存されました: #{clip.inspect}"
      else
        Rails.logger.error "クリップ保存失敗: #{clip_data['id']} - #{clip.errors.full_messages.join(', ')}"
      end
    end
  rescue StandardError => e
    Rails.logger.error "クリップ保存中のエラー: #{clip_data['id']} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end

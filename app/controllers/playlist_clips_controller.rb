# app/controllers/playlist_clips_controller.rb
class PlaylistClipsController < ApplicationController
  before_action :authenticate_user!

  def create
    # フォームから送信されたデータを取得
    playlist_clip_params = create_playlist_clip_params
    Rails.logger.debug("フォームから送信されたデータ #{params.inspect}")

    # クリップIDを取得して数値に変換
    clip_id = playlist_clip_params[:clip_id].to_i
    Rails.logger.debug("Converted Clip ID: #{clip_id}")

    # プレイリストのIDを取得（デフォルトは空配列）
    playlist_ids = params[:playlist_ids] || []

    # 「後で見る」が選択されているかを確認
    watch_later = params[:watch_later] == "true"

    # クリップを取得（存在しない場合は404エラー）
    clip = Clip.find(clip_id)
    Rails.logger.debug("Clip query result: #{clip.inspect}")

    # プレイリストにクリップを追加
    add_clip_to_playlists(clip, playlist_ids)

    # 「後で見る」の処理
    if watch_later
      begin
        add_clip_to_watch_later(clip)
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = "『後で見る』プレイリストを処理中にエラーが発生しました。"
        Rails.logger.error("Failed to process 'Watch Later' playlist: #{e.message}")
        redirect_to request.referrer || search_path, status: :see_other and return
      end
    end

    # 成功メッセージを表示
    flash.now[:success] = "クリップが保存されました！"
    Rails.logger.debug("Clip #{clip.id} successfully added!")
    Rails.logger.error("検索対象者: #{@clips}")

        # ゲームと配信者のクリップ検索を両方実行
        search_query = params[:search_query]
        @games = Game.ransack(name_cont: search_query).result(distinct: true)
        @streamers = Streamer.ransack(streamer_name_or_display_name_cont: search_query).result(distinct: true)

        @clips = []

        # ゲームと配信者のクリップを取得
        # テスト
        game_ids = @games.pluck(:game_id)
        streamer_ids = @streamers.pluck(:streamer_id)

        @clips = Clip.get_game_clips(game_ids) + Clip.get_streamer_clips(streamer_ids)

        # 重複を排除してクリップを一意にする
        @clips = @clips.uniq
        @clips = Kaminari.paginate_array(@clips).page(params[:page]).per(60)
        @search_query = search_query

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "clips",
          partial: "search/clips",
          locals: { clips: @clips, search_query: @search_query }
        )
      }
    end
  end

  private

  # ストロングパラメーターの定義
  def create_playlist_clip_params
    params.permit(:clip_id, :watch_later)
  end

  # プレイリストにクリップを追加
  def add_clip_to_playlists(clip, playlist_ids)
    return if playlist_ids.empty?

    playlist_ids.each do |playlist_id|
      playlist = current_user.playlists.find_by(id: playlist_id)
      if playlist
        unless playlist.clips.exists?(clip.id)
          playlist.clips << clip
          Rails.logger.debug("Clip #{clip.id} added to playlist #{playlist.id}")
        end
      else
        Rails.logger.debug("Playlist with ID #{playlist_id} not found for user #{current_user.id}")
        flash[:warning] = "指定されたプレイリストが見つかりませんでした。"
      end
    end
  end

  # 「後で見る」にクリップを追加
  def add_clip_to_watch_later(clip)
    watch_later_playlist = current_user.playlists.find_or_initialize_by(name: "後で見る")
    watch_later_playlist.assign_attributes(
      user_uid: current_user.uid, # 明示的に user_uid を設定
      is_watch_later: true,
      visibility: "private"
    )

    # プレイリストが新規の場合は保存
    if watch_later_playlist.new_record?
      watch_later_playlist.save!
      Rails.logger.debug("Created new 'Watch Later' playlist: #{watch_later_playlist.inspect}")
    else
      Rails.logger.debug("'Watch Later' playlist already exists: #{watch_later_playlist.inspect}")
    end

    # クリップを追加
    unless watch_later_playlist.clips.exists?(clip.id)
      watch_later_playlist.clips << clip
      Rails.logger.debug("Clip #{clip.id} added to 'Watch Later' playlist #{watch_later_playlist.id}")
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to process 'Watch Later' playlist: #{e.message}")
    raise
  end
end

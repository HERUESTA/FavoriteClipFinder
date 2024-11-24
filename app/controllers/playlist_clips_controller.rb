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
    playlist_ids = playlist_clip_params[:playlist_ids] || []

    # 「後で見る」が選択されているかを確認
    watch_later = playlist_clip_params[:watch_later] == "true"

    # クリップを取得（存在しない場合は404エラー）
    clip = Clip.find(clip_id)

    # フラッシュメッセージを格納する変数
    success_messages = []
    error_messages = []

    # プレイリストにクリップを追加
    if playlist_ids.any?
      playlist_ids.each do |playlist_id|
        playlist = current_user.playlists.find_by(id: playlist_id)
        if playlist
          if playlist.clips.exists?(clip.id)
            error_messages << "プレイリスト「#{playlist.name}」には既にこのクリップが追加されています。"
          else
            playlist.clips << clip
            Rails.logger.debug("Clip #{clip.id} added to playlist #{playlist.id}")
            success_messages << "プレイリスト「#{playlist.name}」にクリップが追加されました。"
          end
        else
          Rails.logger.debug("Playlist with ID #{playlist_id} not found for user #{current_user.id}")
          error_messages << "指定されたプレイリストが見つかりませんでした。"
        end
      end
    else
      error_messages << "プレイリストが選択されていません。"
    end

    # 「後で見る」の処理
    if watch_later
      watch_later_playlist = current_user.playlists.find_or_initialize_by(name: "後で見る")
      watch_later_playlist.assign_attributes(
        user_uid: current_user.uid,
        is_watch_later: true,
        visibility: "private"
      )

      if watch_later_playlist.new_record?
        if watch_later_playlist.save
          Rails.logger.debug("Created new 'Watch Later' playlist: #{watch_later_playlist.inspect}")
        else
          error_messages << "「後で見る」プレイリストの作成に失敗しました。"
        end
      else
        Rails.logger.debug("'Watch Later' playlist already exists: #{watch_later_playlist.inspect}")
      end

      if watch_later_playlist.clips.exists?(clip.id)
        error_messages << "「後で見る」プレイリストには既にこのクリップが追加されています。"
      else
        watch_later_playlist.clips << clip
        Rails.logger.debug("Clip #{clip.id} added to 'Watch Later' playlist #{watch_later_playlist.id}")
        success_messages << "クリップが「後で見る」に追加されました。"
      end
    end

    # 成功とエラーのメッセージをフラッシュに設定
    flash[:notice] = success_messages.join(" ") if success_messages.any?
    flash[:alert] = error_messages.join(" ") if error_messages.any?

    # クリップ検索の準備
    search_query = params[:search_query]
    @games = Game.ransack(name_cont: search_query).result(distinct: true)
    @streamers = Streamer.ransack(streamer_name_or_display_name_cont: search_query).result(distinct: true)

    @clips = Clip.get_game_clips(@games.pluck(:game_id)) + Clip.get_streamer_clips(@streamers.pluck(:streamer_id))
    @clips = @clips.uniq
    @clips = Kaminari.paginate_array(@clips).page(params[:page]).per(60)
    @search_query = search_query

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.prepend("flash_messages", partial: "layouts/flash_messages"),
          turbo_stream.replace(
            "clips",
            partial: "search/clips",
            locals: { clips: @clips, search_query: @search_query }
          )
        ]
      }
      format.html { redirect_to some_path }
    end
  end

  private

  # ストロングパラメーターの定義
  def create_playlist_clip_params
    params.permit(:clip_id, :watch_later, playlist_ids: [])
  end
end

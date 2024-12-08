class PlaylistClipsController < ApplicationController
  before_action :authenticate_user!

  def create
    # フォームから送信されたデータを取得
    set_params

    # クリップを取得
    clip = Clip.find(@clip_id)

    # 「後で見る」が選択されているかを確認
    watch_later = @watch_later == "true"

    # 「後で見る」の処理
    if watch_later
      watch_later_playlist = current_user.playlists.find_or_initialize_by(name: "後で見る")
      # 新規作成の場合の処理
      if watch_later_playlist.new_record?
        watch_later_playlist.save
      watch_later_playlist.assign_attributes(
        user_uid: current_user.uid,
        is_watch_later: true,
      )
      end
      # 該当のクリップがすでにプレイリスト内に存在するかどうか
      search_clip(watch_later_playlist, clip)
    end

    # 通常のプレイリスト作成の処理
    unless watch_later
      if playlist = current_user.playlists.find_or_initialize_by(name: @playlist_name)
        if playlist.new_record?
          playlist.save
        end
        search_clip(playlist, clip)
      end
    end


    # クリップ検索の準備
    search_query = params[:search_query]
    @games = Game.ransack(name_cont: search_query).result(distinct: true)
    @streamers = Streamer.ransack(streamer_name_or_display_name_cont: search_query).result(distinct: true)

    @clips = Clip.get_game_clips(@games.pluck(:game_id)) + Clip.get_streamer_clips(@streamers.pluck(:streamer_id))
    @clips = @clips.uniq
    @clips = Kaminari.paginate_array(@clips).page(params[:page]).per(60)
    @search_query = search_query

    # プレイリストを変数にして渡す
    @playlists = current_user.playlists
  end

  private

  # ストロングパラメーターの定義
  def create_playlist_clip_params
    params.permit(:clip_id, :watch_later, :playlist_name)
  end

  # プレイリストに該当クリップが存在するかどうかの分岐処理
  def search_clip(playlist, clip)
    respond_to do |format|
      if playlist.clips.exists?(@clip_id)
        format.turbo_stream { flash.now[:alert] = "「#{playlist.name}」には既にこのクリップが追加されています。" }
      else
        format.turbo_stream do
          playlist.clips.push(clip)
          flash.now[:notice] = "プレイリスト「#{playlist.name}」にクリップが追加されました。"
        end
      end
    end
  end

  # フォームから送信されたデータを取得
  def set_params
    @playlist_name = params[:playlist_name]
    @visibility = params[:visibility]
    @watch_later = params[:watch_later]
    @clip_id = params[:clip_id]
  end
end
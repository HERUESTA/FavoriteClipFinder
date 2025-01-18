# app/controllers/search_controller.rb
class SearchController < ApplicationController
  def index
    q = params[:q]
      q = Clip.includes(:streamer, :game).ransack(
        combinator: "or",
        game_name_cont: q,
        streamer_streamer_name_cont: q,
        streamer_display_name_cont: q
      )
    @clips = q.result(distinct: true).order(clip_created_at: :desc).page(params[:page]).per(60)

    # ログインしている場合のみプレイリストを渡す
    # 未ログインの場合は空の配列を渡す
    @playlists = current_user&.playlists || []
  end

  def playlist
    # いいね数が多い順にプレイリスト取得
    @playlists = Playlist.where(visibility: "public").includes(:user).order(likes_count: :desc)
  end
end

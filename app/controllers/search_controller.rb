# app/controllers/search_controller.rb
class SearchController < ApplicationController
  def index
    if params[:q].present?
      @q = Clip.includes(:streamer, :game).ransack(
        combinator: "or",
        game_name_cont: params[:q],
        streamer_name_cont: params[:q],
        streamer_display_name_cont: params[:q]
      )
    else
      @q = Clip.includes(:streamer, :game).ransack({})
    end

    @clips = @q.result(distinct: true).order(clip_created_at: :desc).page(params[:page]).per(60)

    # ログインしている場合のみプレイリストを渡す
    @playlists = user_signed_in? ? current_user.playlists : []
  end

  def playlist
    # プレイリスト取得
    @playlists = Playlist.where(visibility: "public").includes(:user).order(likes_count: :desc)
  end
end

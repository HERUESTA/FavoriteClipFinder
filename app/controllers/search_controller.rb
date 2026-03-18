class SearchController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :playlists ]
  PER_PAGE = 30
  def index
    @q = Clip.preload(:broadcaster, :game).ransack(
      combinator: "or",
      game_name_start: params[:q],
      broadcaster_broadcaster_name_eq: params[:q],
      broadcaster_broadcaster_login_eq: params[:q]
    )
    @clips = @q.result(distinct: true).order(clip_created_at: :desc).page(params[:page]).per(PER_PAGE)
    @playlists = user_signed_in? ? current_user.playlists : []
  end

  def playlists
    @playlists = Playlist.where(visibility: "public").preload(:user).order(likes_count: :desc)
  end
end

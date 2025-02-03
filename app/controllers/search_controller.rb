class SearchController < ApplicationController
  def index
    # 検索フォームの値を取得
    if params[:q].present?
      @q = Clip.preload(:broadcaster, :game).ransack(
        combinator: "or",
        game_name_start: params[:q],
        broadcaster_broadcaster_name_eq: params[:q],
        broadcaster_broadcaster_login_eq: params[:q]
      )
    end
    @clips = @q.result(distinct: true).order(clip_created_at: :desc).page(params[:page]).per(30)
    # ログインしている場合のみプレイリストを渡す
    @playlists = user_signed_in? ? current_user.playlists : []
  end

  def playlist
    # いいね数が多い順にプレイリスト取得
    @playlists = Playlist.where(visibility: "public").preload(:user).order(likes_count: :desc)
  end
end

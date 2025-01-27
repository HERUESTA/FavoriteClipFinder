# app/controllers/search_controller.rb
class SearchController < ApplicationController
  def index
    # 検索フォームの値を取得
    if params[:q].present?
      @q = Clip.preload(:streamer, :game).ransack(
        combinator: "or",
        game_name_cont: params[:q],
        streamer_streamer_name_cont: params[:q],
        streamer_display_name_cont: params[:q]
      )
    else
      # キーワードがない場合は全てのクリップを取得
      @q = Clip.preload(:streamer, :game).ransack({})
    end
    @clips = @q.result(distinct: true).order(clip_created_at: :desc).page(params[:page]).per(60)
    # ログインしている場合のみプレイリストを渡す
    @playlists = user_signed_in? ? current_user.playlists : []
  end

  def playlist
    # いいね数が多い順にプレイリスト取得
    @playlists = Playlist.where(visibility: "public").preload(:user).order(likes_count: :desc)
  end
end

# app/controllers/search_controller.rb
class SearchController < ApplicationController
  def index
    # 検索フォームの値を取得
    if params[:q].present?

      # includeで関連テーブルを取得
      @q = Clip.includes(:streamer, :game).ransack(
        # 複数の検索条件をORで結合
        combinator: "or",
        # ゲーム名を含む
        game_name_cont: params[:q],
        # 配信者名を含む
        streamer_streamer_name_cont: params[:q],
        # 配信者の表示名を含む
        streamer_display_name_cont: params[:q]
      )
    else
      # キーワードがない場合は全てのクリップを取得
      @q = Clip.includes(:streamer, :game).ransack({})
    end

    # @qを使って、検索結果を取得
    @clips = @q.result(distinct: true).order(clip_created_at: :desc).page(params[:page]).per(60)

    # ログインしている場合のみプレイリストを渡す
    @playlists = user_signed_in? ? current_user.playlists : []
  end

  def playlist
    # いいね数が多い順にプレイリスト取得
    @playlists = Playlist.where(visibility: "public").includes(:user).order(likes_count: :desc)
  end
end

# app/controllers/playlists_controller.rb
class PlaylistsController < ApplicationController
  # ユーザーが認証されていることを確認
  before_action :authenticate_user!
  # 特定のアクション前にプレイリストを設定
  before_action :set_playlist, only: [ :update, :destroy ]

  # 明示的に application レイアウトを使用
  layout "application"

  def index
    @page = params[:page]
    @active_tab = (params[:active_tab] == "liked_playlists") ? "liked_playlists" : "my_library"
    # いいねしたプレイリスト
    @liked_playlists = Playlist.get_liked_playlists(current_user, @page)
    # マイライブラリ
    @my_playlists = Playlist.get_my_playlists(current_user, @page)
  end

  def edit
    @playlist = Playlist.find(params[:id])
    @clips = @playlist.clips.includes(:streamer)
  end

  def show
    # プレイリスト内の全クリップを取得
    @playlist = Playlist.find(params[:id])
    @clips = @playlist.clips.includes(:streamer)

    # 再生するクリップを特定（パラメータがなければ最初のクリップを使用）
    @clip = params[:clip_id].present? ? @clips.find_by(id: params[:clip_id]) : @clips.first
  end

  # プレイリストを更新
  def update
    Rails.logger.debug "プレイリストの中身: #{@playlist.inspect}"
    @playlist.update(playlist_params)
      respond_to do |format|
        format.html { redirect_to request.referer, notice: "#{@playlist.title}を更新しました" }
      end
  end

  # プレイリストを削除
  def destroy
    @playlist.destroy!
    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = "#{@playlist.title}を削除しました" }
      format.html { redirect_to show_path, notice: "#{@playlist.title}を削除しました", status: :see_other }
    end
  end

  private

  # プレイリストを設定するメソッド
  def set_playlist
    # 現在のユーザーが所有するプレイリストのみを検索
    @playlist = current_user.playlists.find(params[:id])
    @playlists = current_user.playlists.order(:id)
  end

  # ストロングパラメータの定義
  def playlist_params
    params.require(:playlist).permit(:title, :visibility, :id)
  end
end

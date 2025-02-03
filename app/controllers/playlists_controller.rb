# app/controllers/playlists_controller.rb
class PlaylistsController < ApplicationController
  before_action :authenticate_user!, only: [ :edit, :index, :update, :destroy ]
  before_action :search_current_user_playlist, only: [ :update, :destroy ]
  before_action :ensure_correct_user, only: [ :edit ]

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
    @clips = @playlist.clips.preload(:broadcaster)
  end

  def show
    @playlist = Playlist.find(params[:id])
    confirm_privacy(@playlist)
    @clips = @playlist.clips.preload(:broadcaster)
    @playlists = user_signed_in? ? Playlist.where(user_uid: current_user.uid) : []
    @clip = params[:clip_id].present? ? @clips.find_by(id: params[:clip_id]) : @clips.first
  end

  def update
    @playlist.update(playlist_params)
      respond_to do |format|
        format.html { redirect_to request.referer, notice: t("playlists.updated", title: @playlist.title) }
      end
  end

  def destroy
    @playlist.destroy!
    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = t("playlists.destroy", title: @playlist.title) }
      format.html { redirect_to playlists_path, notice: t("playlists.destroy", title: @playlist.title), status: :see_other }
    end
  end

  private

  def search_current_user_playlist
    @playlist = current_user.playlists.find(params[:id])
    @playlists = current_user.playlists.order(:id)
  end

  def ensure_correct_user
    @playlist = Playlist.find(params[:id])
    unless @playlist.user_uid == current_user.uid
      redirect_to root_path, alert: "このプレイリストを編集する権限がありません"
    end
  end

  def confirm_privacy(playlist)
    if playlist.nil? || playlist.visibility == "private" && current_user.uid != playlist.user_uid
      redirect_to root_path, alert: "このプレイリストにはアクセスができません"
    end
  end

  def playlist_params
    params.require(:playlist).permit(:title, :visibility, :id)
  end
end

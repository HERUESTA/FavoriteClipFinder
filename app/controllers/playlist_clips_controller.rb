class PlaylistClipsController < ApplicationController
  before_action :authenticate_user!


  def create
    playlist = Playlist.new(playlist_params)
    if playlist.save
      save_clip_in_plalist(playlist)
    else
      flash[:error] = "プレイリストを作成できませんでした"
    end
    redirect_to request.referer
  end

  def destroy
    @clip = Clip.find(params[:clip_id])
    @playlist = Playlist.find(params[:id])
    @playlist.clips.destroy(@clip)
    if @playlist.clips.exists?
      @playlist.destroy!
      redirect_to playlists_path, notice: "クリップを全て削除したためプロフィール画面へ移動しました", status: :see_other
    else
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "該当のクリップを削除しました" }
        format.html { redirect_to edit_playlist_path(@playlist), notice: "該当のクリップを削除しました", status: :see_other }
      end
    end
  end

  # 既存のプレイリストにクリップを追加する
  def add_clip_in_playlist
    playlist = Playlist.find_by(id: params[:playlist_id])
    clip = Clip.find(params[:clip_id])
    unless playlist.clips.include?(clip)
      playlist.clips << clip
      flash[:notice] = "#{playlist.title}にクリップを追加しました"
    else
      flash[:error] = "#{playlist.title}にすでに該当のクリップが追加されています"
    end
    redirect_to request.referer
  end

  private

  def save_clip_in_plalist(playlist)
    clip = Clip.find_by(id: params[:clip_id])
    if playlist.clips << clip
      flash[:notice] = "#{playlist.title}にクリップを追加しました"
    else
      flash[:error] = "#{playlist.title}にクリップを追加できませんでした"
    end
  end

  # ストロングパラメーターの定義
  def playlist_params
    params.permit(:title, :visibility, :user_uid)
  end
end

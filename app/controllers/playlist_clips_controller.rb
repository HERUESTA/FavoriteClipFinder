class PlaylistClipsController < ApplicationController
  def create
    playlist = Playlist.new(playlist_params)
    if playlist.save
      save_clip_in_plalist(playlist)
    else
      flash[:error] = t("playlist_clips.create.normal")
    end
    redirect_to request.referer
  end

  def destroy
    @clip = Clip.find(params[:clip_id])
    @playlist = Playlist.find(params[:id])
    @playlist.clips.destroy(@clip)
    if @playlist.clips.empty?
      @playlist.destroy!
      redirect_to playlists_path, notice: t("playlist_clips.destroy.all"), status: :see_other
    else
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = t("playlist_clips.destroy.one") }
        format.html { redirect_to edit_playlist_path(@playlist), notice: t("playlist_clips.destroy.one"), status: :see_other }
      end
    end
  end

  # 既存のプレイリストにクリップを保存する
  # updateアクションに飛べないのでこちらのメソッドで代替する
  # (playlistIDを特定することができないため)
  def add_clip_in_playlist
    playlist = Playlist.find_by(id: params[:playlist_id])

    clip = Clip.find(params[:clip_id])
    unless playlist.clips.include?(clip)
      playlist.clips << clip
      flash[:notice] = t("playlist_clips.update.notice", title: playlist.title)
    else
      flash[:error] = t("playlist_clips.update.error", title: playlist.title)
    end
    redirect_to request.referer
  end

  private

  def save_clip_in_plalist(playlist)
    clip = Clip.find_by(id: params[:clip_id])
    if playlist.clips << clip
      flash[:notice] = t("playlist_clips.create.notice", title: playlist.title)
    else
      flash[:error] = t("playlist_clips.create.error", title: playlist.title)
    end
  end

  def playlist_params
    params.permit(:title, :visibility, :user_uid)
  end
end

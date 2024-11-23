# app/controllers/playlists_controller.rb
class PlaylistsController < ApplicationController
  def show
    @playlist = Playlist.find(params[:id])
    @clips = @playlist.clips # プレイリスト内のクリップを取得
  end
end

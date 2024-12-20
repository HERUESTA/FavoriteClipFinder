class TopsController < ApplicationController
  # TOP画面に遷移
  def index
    if current_user.present?
      Rails.logger.debug "現在のユーザー: #{current_user}"
      # トークンの期限が存在し、期限が切れている場合はリフレッシュ
      if current_user.token_expires_at.present? && current_user.token_expires_at < Time.now
        current_user.refresh_access_token(current_user)
      end
    end

    # プレイリスト取得
    @playlists = Playlist.where(visibility: "public").limit(20)
    @my_playlists = Playlist.where(user_uid: current_user.uid)
    # クリップの取得
    @GTA_clips = Clip.for_game(Clip::GAME_ID[:GTA])
    @Apex_clips = Clip.for_game(Clip::GAME_ID[:APEX])
    @Street_fighter_clips = Clip.for_game(Clip::GAME_ID[:SF6])
    @VALORANT_clips = Clip.for_game(Clip::GAME_ID[:VALORANT])
    @LOL_clips = Clip.for_game(Clip::GAME_ID[:LOL])
  end
end

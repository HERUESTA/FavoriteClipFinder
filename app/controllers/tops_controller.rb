class TopsController < ApplicationController
  PER_PAGE = 20
  def index
    if current_user.present?
      # トークンの期限が存在し、期限が切れている場合はリフレッシュ
      refresh_token_if_expired
    end

    @playlists = Playlist
                  .where(visibility: "public")
                  .preload(:user)
                  .order(created_at: :desc)
                  .limit(PER_PAGE)
    if current_user
      @my_playlists = Playlist.where(user_uid: current_user.uid)
    else
      @my_playlists = []
    end
    @GTA_clips = Clip.for_game(Clip::GAME_ID[:GTA])
    @Apex_clips = Clip.for_game(Clip::GAME_ID[:APEX])
    @Street_fighter_clips = Clip.for_game(Clip::GAME_ID[:SF6])
    @VALORANT_clips = Clip.for_game(Clip::GAME_ID[:VALORANT])
    @LOL_clips = Clip.for_game(Clip::GAME_ID[:LOL])
  end

  private
  def refresh_token_if_expired
    return unless current_user.present?
    if current_user.token_expires_at.present? && current_user.token_expires_at < Time.current
      current_user.refresh_access_token!
    end
  end
end

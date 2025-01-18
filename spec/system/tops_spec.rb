require 'rails_helper'

RSpec.describe "Tops", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe 'トップページ（TopsController#index）' do
    let!(:user) { create(:user) } # ログインユーザーを用意
    # 公開ずみプレイリスト作成
    let!(:public_playlist) do
      playlist = create(:playlist, visibility: 'public', user: user)
      clip = create(:clip)
      create(:playlist_clip, playlist: playlist, clip: clip)
    end
    let!(:private_playlists) { create_list(:playlist, 3, visibility: 'private', user: user) }

    # ゲームごとのクリップを生成
    let!(:game_apex) { create(:game, game_id: Clip::GAME_ID[:APEX]) }
    let!(:game_gta) { create(:game, game_id: Clip::GAME_ID[:GTA]) }
    let!(:game_sf6) { create(:game, game_id: Clip::GAME_ID[:SF6]) }
    let!(:game_valorant) { create(:game, game_id: Clip::GAME_ID[:VALORANT]) }
    let!(:game_lol) { create(:game, game_id: Clip::GAME_ID[:LOL]) }

    # それぞれクリップを作成
    let!(:gta_clips) { create_list(:clip, 3, game_id: Clip::GAME_ID[:GTA]) }
    let!(:apex_clips) { create_list(:clip, 3, game_id: Clip::GAME_ID[:APEX]) }
    let!(:sf6_clips) { create_list(:clip, 3, game_id: Clip::GAME_ID[:SF6]) }
    let!(:valorant_clips) { create_list(:clip, 3, game_id: Clip::GAME_ID[:VALORANT]) }
    let!(:lol_clips) { create_list(:clip, 3, game_id: Clip::GAME_ID[:LOL]) }

    context 'ユーザーがログインしていない場合' do
      it 'トップページにアクセスするとpublicのプレイリストのみが表示される' do
        visit root_path
        expect(page).to have_content(public_playlist.playlist.title)
        expect(page).to have_content(public_playlist.playlist.user.user_name)

        private_playlists.each do |playlist|
          expect(page).not_to have_content(playlist.title)
        end
      end

      it '各ログインのクリップ一覧が表示されていること' do
        visit root_path

        apex_clips.each do |clip|
          expect(page).to have_content(clip.title)
        end
      end
    end
  end
end

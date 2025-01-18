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
    # 非公開プレイリスト作成
    let!(:private_playlist) do
      playlist = create(:playlist, visibility: 'private', user: user)
      clip = create(:clip)
      create(:playlist_clip, playlist: playlist, clip: clip)
    end

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

    context 'TOP画面に遷移する場合' do
      it 'トップページにアクセスするとpublicのプレイリストのみが表示される' do
        visit root_path
        expect(page).to have_content(public_playlist.playlist.title)
        expect(page).to have_content(public_playlist.playlist.user.user_name)

        expect(page).not_to have_content(private_playlist.playlist.title)
      end

      it '各クリップ一覧が表示されていること' do
        visit root_path
        apex_clips.each do |clip|
          expect(page).to have_content(clip.title)
        end
      end

      it 'アイコンを押下すると、TOP画面に遷移する'  do
        visit root_path
        click_on "ロゴ"
        expect(page).to have_current_path(root_path)
      end
    end
  end
end

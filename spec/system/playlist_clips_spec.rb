require 'rails_helper'

RSpec.describe "PlaylistClips", type: :system do
  include Warden::Test::Helpers
  before do
    driven_by(:rack_test)
  end
  let!(:user) { create(:user) }

  describe 'ログイン後' do
    describe 'プレイリスト新規作成' do
      before do
        login_as(user)
      end

      let!(:apex) { create(:game, game_id: Clip::GAME_ID[:APEX]) }
      let!(:clip) { create(:clip, game: apex) }

      context 'プレイリスト新規作成' do
        it 'プレイリスト作成が成功する' do
          visit root_path
          find('label.bg-gray.text-purple-600', text: '保存').click
          fill_in 'title', with: 'title'
          click_button '作成'
          expect(page).to have_content("titleにクリップを追加しました")
        end
      end
    end

    describe 'プレイリストのクリップ追加' do
      before do
        login_as(user)
      end

      let!(:apex) { create(:game, game_id: Clip::GAME_ID[:APEX]) }
      let!(:same_clip) { create(:clip, game: apex) }

      let!(:my_playlist) do
        playlist = create(:playlist, visibility: 'public', user: user)
        clip = create(:clip)
        create(:playlist_clip, playlist: playlist, clip: clip)
      end

      let!(:same_playlist) do
        playlist = create(:playlist, visibility: 'public', user: user)
        create(:playlist_clip, playlist: playlist, clip: same_clip)
      end

      context 'プレイリストのクリップ追加' do
        it 'プレイリストのクリップ追加が成功する' do
          visit root_path
          find('label.bg-gray.text-purple-600', text: '保存').click
          click_button '保存'
          expect(page).to have_content("#{my_playlist.playlist.title}にクリップを追加しました")
        end

        it 'プレイリストにすでにあるクリップを追加する' do
          same_playlist
          visit root_path
          find('label.bg-gray.text-purple-600', text: '保存').click
          choose "#{same_playlist.playlist.title}"
          click_button '保存'
          expect(page).to have_content("#{same_playlist.playlist.title}にすでに該当のクリップが追加されています")
        end
      end
    end

    describe 'プレイリスト内のクリップ削除' do
      before do
        login_as(user)
      end

      let!(:my_playlist) do
        playlist = create(:playlist, visibility: 'public', user: user)
        clips = create_list(:clip, 3)
        clips.each do |clip|
          create(:playlist_clip, playlist: playlist, clip: clip)
        end
        playlist
      end

      let!(:one_playlist) do
        playlist = create(:playlist, visibility: 'public', user: user)
        clip = create(:clip)
        create(:playlist_clip, playlist: playlist, clip: clip)
        playlist
      end

      context 'プレイリスト内のクリップ削除' do
        it 'プレイリストのクリップを削除する' do
          visit edit_playlist_path(my_playlist.id)
          target_clip = my_playlist.clips.first
          within("#clip_#{target_clip.id}") do
            expect(page).to have_selector('a[title="削除"]', visible: true)
            find('a[title="削除"]').click
          end
          expect(page).to have_content("クリップを削除しました")
        end

        it 'プレイリストの最後のクリップを削除する' do
          visit edit_playlist_path(one_playlist.id)
          target_clip = one_playlist.clips.first
          within("#clip_#{target_clip.id}") do
          expect(page).to have_selector('a[title="削除"]', visible: true)
          find('a[title="削除"]').click
          end
          expect(page).to have_content("クリップを全て削除したためプロフィール画面へ移動しました")
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "Playlists", type: :system do
  include LoginMacros
  before do
    driven_by(:rack_test)
  end
  let(:user) { create(:user) }

  describe 'ログイン前' do
    context 'ログインページに遷移する' do
      let!(:other_user) { create(:user) }

      let!(:playlist) do
        playlist = create(:playlist, visibility: 'public', user: other_user)
        clip = create(:clip)
        create(:playlist_clip, playlist: playlist, clip: clip)
      end

      it '編集ページに遷移した場合' do
        visit edit_playlist_path(playlist.id)
        expect(current_path).to eq(user_session_path)
        expect(page).to have_content("続行するにはログインまたは登録が必要です。")
      end

      it 'indexページに遷移した場合' do
        visit playlists_path
        expect(current_path).to eq(user_session_path)
        expect(page).to have_content("続行するにはログインまたは登録が必要です。")
      end
    end
  end

  describe 'ログイン後' do
    describe 'プレイリスト編集画面' do
      before { login_as(user) }

      let!(:other_user) { create(:user) }

      let!(:my_playlist) do
        playlist = create(:playlist, visibility: 'public', user: user)
        clip = create(:clip)
        create(:playlist_clip, playlist: playlist, clip: clip)
      end

      let!(:edit_playlist) do
        playlist = create(:playlist, visibility: 'public', user: other_user)
        playlist.update(user_uid: other_user.uid)
        clip = create(:clip)
        create(:playlist_clip, playlist: playlist, clip: clip)
      end

      context '他ユーザーのプレイリスト編集画面にアクセス' do
        it '編集ページへのアクセスが失敗する' do
          visit edit_playlist_path(edit_playlist.id)
          expect(page).to have_content("このプレイリストを編集する権限がありません")
        end
      end

      context 'プレイリストを編集する' do
        it 'タイトルが未入力' do
          visit edit_playlist_path(my_playlist.playlist.id)
          find('button[title="編集"]').click
          fill_in 'プレイリスト名', with: ''
          click_button '変更'
          expect(page).to have_content("プレイリスト名を入力してください。")
        end

        it 'タイトルを入力' do
          visit edit_playlist_path(my_playlist.playlist.id)
          find('button[title="編集"]').click
          fill_in 'プレイリスト名', with: 'title'
          click_button '変更'
          expect(page).to have_content("titleを更新しました")
        end

        it 'タイトルが30文字以上' do
          visit edit_playlist_path(my_playlist.playlist.id)
          find('button[title="編集"]').click
          fill_in 'プレイリスト名', with: 'a * 31'
          click_button '変更'
          expect(page).to have_content("プレイリスト名が長すぎます。")
        end
      end
    end
  end
end

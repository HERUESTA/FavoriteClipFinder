require 'rails_helper'

RSpec.describe "Playlists", js: true, type: :system do
  include Warden::Test::Helpers
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
      before do
        login_as(user)
      end

      let(:other_user) { create(:user) }

      let(:my_playlist) do
        playlist = create(:playlist, visibility: 'public', user: user)
        clip = create(:clip)
        create(:playlist_clip, playlist: playlist, clip: clip)
      end

      let(:edit_playlist) do
        playlist = create(:playlist, visibility: 'public', user: other_user)
        clip = create(:clip)
        create(:playlist_clip, playlist: playlist, clip: clip)
      end

      context '他ユーザーのプレイリスト編集画面にアクセス' do
        it '編集ページへのアクセスが失敗する' do
          visit edit_playlist_path(edit_playlist.playlist.id)
          expect(page).to have_content("このプレイリストを編集する権限がありません")
        end
      end

      context 'プレイリストを編集する' do
        it 'タイトルが未入力' do
          visit edit_playlist_path(my_playlist.playlist.id)
          find('button[title="編集"]').click
          fill_in 'playlist[title]', with: ''
          click_button '変更'
          expect(page).to have_content("プレイリスト名を入力してください。")
        end

        it 'タイトルを入力' do
          visit edit_playlist_path(my_playlist.playlist.id)
          find('button[title="編集"]').click
          fill_in 'playlist[title]', with: 'title'
          click_button '変更'
          expect(page).to have_content("titleを更新しました")
        end

        it 'タイトルが30文字以上' do
          visit edit_playlist_path(my_playlist.playlist.id)
          find('button[title="編集"]').click
          fill_in 'playlist[title]', with: 'a' * 31
          click_button '変更'
          expect(page).to have_content("プレイリスト名が長すぎます。")
        end
      end
    end

    describe 'プレイリスト削除' do
      before do
        login_as(user)
      end

      let(:other_user) { create(:user) }

      let!(:my_playlist) do
        playlist = create(:playlist, visibility: 'public', user: user)
        clip = create(:clip)
        create(:playlist_clip, playlist: playlist, clip: clip)
      end

      let(:edit_playlist) do
        playlist = create(:playlist, visibility: 'public', user: other_user)
        clip = create(:clip)
        create(:playlist_clip, playlist: playlist, clip: clip)
      end
      context 'プレイリストを削除する' do
        it 'プレイリストの削除に成功する' do
          my_playlist
          visit playlists_path
          find("label.btn.btn-ghost").click
          click_on "削除"
          expect(page).to have_content("#{my_playlist.playlist.title}を削除しました")
        end
      end

      describe 'プレイリスト詳細' do
        before do
          login_as(user)
        end

        let(:other_user) { create(:user) }

        let(:my_playlist) do
          playlist = create(:playlist, visibility: 'public', user: user)
          clip = create(:clip)
          create(:playlist_clip, playlist: playlist, clip: clip)
        end

        let(:other_playlist) do
          playlist = create(:playlist, visibility: 'public', user: user)
          clip = create(:clip)
          create(:playlist_clip, playlist: playlist, clip: clip)
        end

        let(:private_playlist) do
          playlist = create(:playlist, visibility: 'private', user: other_user)
          clip = create(:clip)
          create(:playlist_clip, playlist: playlist, clip: clip)
        end

        context 'プレイリスト詳細画面に遷移する' do
          it 'ログイン状態で遷移できる' do
            visit playlist_path(my_playlist.playlist.id)
            expect(current_path).to eq(playlist_path(my_playlist.playlist.id))
          end

          it '他のユーザーのプレイリストを閲覧できる' do
            visit playlist_path(other_playlist.playlist.id)
            expect(current_path).to eq(playlist_path(other_playlist.playlist.id))
          end

          it '非公開のプレイリストに遷移した時に、エラーメッセージを表示させる' do
            visit playlist_path(private_playlist.playlist.id)
            expect(page).to have_content("このプレイリストにはアクセスができません")
          end
        end
      end
    end
  end
end

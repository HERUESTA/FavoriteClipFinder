require 'rails_helper'

RSpec.describe "Searches", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe '検索ページ（SearchController#index）' do
    context '検索フォームに値を入力した場合' do
      let!(:game) { create(:game) }
      let!(:game_clip) { create(:clip, game: game) }
      let!(:broadcaster) { create(:broadcaster) }
      let!(:broadcaster_clip) { create(:clip, broadcaster: broadcaster) }
      let!(:broadcaster_display_name_clip) { create(:clip, broadcaster: broadcaster) }

      it 'ゲーム名を入力した場合ゲーム名のクリップが表示されること' do
        visit search_path
        fill_in 'q', with: game.name
        find('button[type="submit"]').click
        expect(page).to have_content(game_clip.title)
      end

      it '配信者名を入力した場合配信者名のクリップが表示されること' do
        visit search_path
        fill_in 'q', with: broadcaster.broadcaster_name
        find('button[type="submit"]').click
        expect(page).to have_content(broadcaster_clip.title)
      end

      it '配信者の表示名を入力した場合配信者名のクリップが表示されること' do
        visit search_path
        fill_in 'q', with: broadcaster.broadcaster_login
        find('button[type="submit"]').click
        expect(page).to have_content(broadcaster_display_name_clip.title)
      end

      it '検索フォームに不当な値を入力した場合、エラー画面が表示されること' do
        visit search_path
        fill_in 'q', with: '不当な値'
        find('button[type="submit"]').click
        expect(page).to have_content("現在のキーワードに該当するクリップが存在しておりません")
      end
    end
  end

  describe 'プレイリストページ（SearchController#playlist）' do
    context 'プレイリストページに遷移した場合' do
      let!(:user) { create(:user) }
      let!(:user2) { create(:user) }
      let!(:user3) { create(:user) }
      let!(:user4) { create(:user) }
      let!(:user5) { create(:user) }
      let!(:user6) { create(:user) }

      # 公開済みのプレイリストを作成
      let!(:public_playlist) do
        playlist = create(:playlist, visibility: 'public', user: user)
        clip = create(:clip)
        create(:playlist_clip, playlist: playlist, clip: clip)
      end
      # 非公開のプレイリストを作成
      let!(:private_playlist) do
        playlist = create(:playlist, visibility: 'private', user: user)
        clip = create(:clip)
        create(:playlist_clip, playlist: playlist, clip: clip)
      end

      # いいね数が3のプレイリストを作成
      let!(:playlist_3_likes_playlist) do
        playlist_like_three = create(:playlist, user: user2)
        create(:like, user: user, playlist: playlist_like_three)
        create(:like, user: user3, playlist: playlist_like_three)
        create(:like, user: user4, playlist: playlist_like_three)
        clip = create(:clip)
        create(:playlist_clip, playlist: playlist_like_three, clip: clip)
      end

      # いいね数が2のプレイリストを作成
      let!(:playlist_2_likes_playlist) do
        playlist_like_two = create(:playlist, user: user3)
        create(:like, user: user, playlist: playlist_like_two)
        create(:like, user: user2, playlist: playlist_like_two)
        create(:playlist_clip, playlist: playlist_like_two, clip: create(:clip))
      end

      # いいね数が1のプレイリストを作成
      let!(:playlist_1_likes_playlist) do
        playlist_like_one = create(:playlist, user: user4)
        create(:like, user: user, playlist: playlist_like_one)
        create(:playlist_clip, playlist: playlist_like_one, clip: create(:clip))
      end

      it '公開プレイリストのみが表示されること' do
        visit search_playlist_path
        expect(page).to have_content(public_playlist.playlist.title)
        expect(page).not_to have_content(private_playlist.playlist.title)
      end

      it 'いいね数が多い順にプレイリストが表示されること' do
        visit search_playlist_path
        # いいね数順にプレイリストが表示されていること
        expect(page.text).to match(
          /#{playlist_3_likes_playlist.playlist.title}[\s\S]*#{playlist_2_likes_playlist.playlist.title}[\s\S]*#{playlist_1_likes_playlist.playlist.title}/
        )
      end
    end
  end
end

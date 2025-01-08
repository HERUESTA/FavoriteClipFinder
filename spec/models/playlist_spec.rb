require 'rails_helper'

RSpec.describe Playlist, type: :model do
  describe 'バリデーション' do
    it '設定したすべてのバリデーションが機能しているか' do
      playlist = build(:playlist)
      expect(playlist).to be_valid
      expect(playlist.errors).to be
    end

    it 'titleが空欄の場合バリデーションが通らない' do
      playlist_without_title = build(:playlist, title: nil)
      expect(playlist_without_title).to be_invalid
      expect(playlist_without_title.errors[:title]).to include("を入力してください", "は1文字以上で入力してください")
    end

    it 'titleが31文字以上の場合バリデーションが通らない' do
      playlist_over_title = build(:playlist, title: "a" * 31)
      expect(playlist_over_title).to be_invalid
      expect(playlist_over_title.errors[:title]).to include("は30文字以内で入力してください")
    end
  end

  describe 'インスタンスメソッド' do
    describe '#liked_by?' do
      let(:user) { create(:user) }
      let(:playlist) { create(:playlist) }
      context 'ユーザーがいいねしている場合' do
        before do
          create(:like, user_uid: user.uid, playlist: playlist)
        end

        it 'trueを返す' do
          expect(playlist.liked_by?(user)).to be true
        end
      end

      context 'ユーザーがいいねしていない場合' do
        it 'falseを返す' do
          expect(playlist.liked_by?(user)).to be false
        end
      end

      context 'ユーザーがnilの場合' do
        it 'falseを返す' do
          expect(playlist.liked_by?(nil)).to be false
        end
      end
    end
  end

  # クラスメソッドのテスト
  describe 'クラスメソッド' do
    describe '.get_liked_playlists' do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }
      let!(:liked_playlist) { create(:playlist, user: other_user) }
      let!(:like) { create(:like, user: user, playlist: liked_playlist) }
      let!(:own_playlists) { create_list(:playlist, 2, user: user) }
      let!(:other_playlists) { create_list(:playlist, 2) }

      it 'ユーザーがいいねした自分以外のプレイリストを取得する' do
        result = Playlist.get_liked_playlists(user, 1)
        liked_playlist.reload
        expect(result).to eq([ liked_playlist ])
      end

      it 'ページネーションが正しく機能する' do
        pagenation_playlists = create_list(:playlist, 5)
        pagenation_playlists.each do |playlist|
          create(:like, user: user, playlist: playlist)
        end
        result = Playlist.get_liked_playlists(user, 1)
        expect(result.size).to eq(6)
      end
    end

    describe '.get_my_playlists' do
      let(:user) { create(:user) }
      let!(:my_playlists) { create_list(:playlist, 5, user: user) }
      let!(:other_playlists) { create_list(:playlist, 3) }

      it 'ユーザーのプレイリストのみを取得する' do
        result = Playlist.get_my_playlists(user, 1)
        expect(result).to match_array(my_playlists)
        expect(result).not_to include(other_playlists)
      end

      it 'ページネーションが正しく機能する' do
        # Assuming we have more than 6 playlists
        create_list(:playlist, 2, user: user)
        result = Playlist.get_my_playlists(user, 1)
        expect(result.size).to eq(6)
      end

      it 'ページネーションが2ページ以上正しく機能する' do
        create_list(:playlist, 3, user: user)
        result = Playlist.get_my_playlists(user, 2)
        expect(result.size).to eq(2)
      end
    end
  end
end

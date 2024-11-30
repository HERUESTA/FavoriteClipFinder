class Playlist < ApplicationRecord
  # 関連付け
  belongs_to :user, foreign_key: "user_uid", primary_key: "uid"

  has_many :playlist_clips, dependent: :destroy
  has_many :clips, through: :playlist_clips
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

   # 公開プレイリストのスコープ
   scope :public_playlists, -> { where(visibility: "public") }
   # 非公開プレイリストのスコープ
   scope :private_playlists, -> { where(visibility: "private") }

  # バリデーション
  validates :name, presence: true

  # カラムの値を簡単に操作するメソッドを追加
  def increment_likes
    self.increment!(:likes)
  end

  def decrement_likes
    self.decrement!(:likes) if likes > 0
  end
end

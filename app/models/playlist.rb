class Playlist < ApplicationRecord
  # 関連付け
  belongs_to :user, foreign_key: "user_uid", primary_key: "uid"

  has_many :playlist_clips, dependent: :destroy
  has_many :clips, through: :playlist_clips
  has_many :likes, dependent: :destroy
  has_many :users, through: :likes, source: :user

   # 公開プレイリストのスコープ
   scope :public_playlists, -> { where(visibility: "public") }
   # 非公開プレイリストのスコープ
   scope :private_playlists, -> { where(visibility: "private") }

  # バリデーション
  validates :title, presence: true
  validates :title, length: { in: 1..30 }

  # いいねしているかどうか
  def like_by?(user)
  return false if user.nil?
  likes.exists?(user_uid: user.uid)
  end

  # いいねしたプレイリストを取得する
  def self.get_liked_playlists(user, page)
    @playlists = Playlist.joins(:likes).where(likes: { user_uid: user.uid }).where.not(playlists: { user_uid: user.uid })
    @playlists = @playlists.order(:id)
    @playlists = Kaminari.paginate_array(@playlists).page(page).per(6)
  end

  # マイプレイリストを取得する
  def self.get_my_playlists(user, page)
    @playlists = user.playlists
    @playlists = @playlists.order(:id)
    @playlists = Kaminari.paginate_array(@playlists).page(page).per(6)
  end
end

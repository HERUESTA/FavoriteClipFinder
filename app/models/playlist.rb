class Playlist < ApplicationRecord
  # 関連付け
  belongs_to :user, foreign_key: "user_uid", primary_key: "uid"

  has_many :playlist_clips, dependent: :destroy
  has_many :clips, through: :playlist_clips
  has_many :likes, dependent: :destroy
  has_many :users, through: :likes, source: :user

  # バリデーション
  validates :title, presence: true
  validates :title, length: { in: 1..30 }

  # いいねしているかどうか
  def liked_by?(user)
    likes.exists?(user_uid: user&.uid)
  end

  # いいねした自分以外のプレイリストを取得する
  def self.get_liked_playlists(current_user, page)
    playlists = Playlist.joins(:likes)
                .where(likes: { user_uid: current_user.uid })
                .where.not(user_uid: current_user.uid)
                .distinct
    # いいねした日時の新しい順に取得
    playlists.eager_load(:likes).order("likes.created_at DESC").page(page).per(6)
  end

  # マイプレイリストを取得する
  def self.get_my_playlists(current_user, page)
    current_user.playlists.order(:id).page(page).per(6)
  end
end

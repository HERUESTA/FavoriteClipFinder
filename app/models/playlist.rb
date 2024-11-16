class Playlist < ApplicationRecord
  # 関連付け
  belongs_to :user, foreign_key: 'user_uid'

  has_many :playlist_clips, dependent: :destroy
  has_many :clips, through: :playlist_clips

  # バリデーション
  validates :name, presence: true
end
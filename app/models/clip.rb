class Clip < ApplicationRecord
  # アソシエーション
  belongs_to :streamer, class_name: "Streamer", foreign_key: "streamer_id"
  belongs_to :game, class_name: "Game", foreign_key: "game_id"

  has_many :playlist_clips, dependent: :destroy
  has_many :playlists, through: :playlist_clips

  has_many :fovorite_clips, dependent: :destroy
  has_many :favorited_by, through: :favorite_clips, source: :user

  # バリデーション
  validates :clip_id, presence: true, uniqueness: true
  validates :streamer_id, presence: true
  validates :game_id, presence: true
  validates :title, presence: true
  validates :duration, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :view_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end

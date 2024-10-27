class Streamer < ApplicationRecord
  # アソシエーション
  has_many :clips, foreign_key: "streamer_id", dependent: :destroy

  # バリデーション
  validates :login, presence: true, uniqueness: true
  validates :display_name, presence: true
end

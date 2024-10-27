class Game < ApplicationRecord
  # アソシエーション
  has_many :clips, foreign_key: "game_id", dependent: :destroy

  # バリデーション
  validates :name, presence: true, uniqueness: true
end

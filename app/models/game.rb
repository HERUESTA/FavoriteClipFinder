# app/models/game.rb

class Game < ApplicationRecord
  has_many :clips, foreign_key: :game_id, primary_key: :id

  validates :game_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :box_art_url, presence: true
  # 他の必要なバリデーションや関連付けを追加
end

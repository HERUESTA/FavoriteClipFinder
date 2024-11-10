# app/models/game.rb

class Game < ApplicationRecord
  has_many :clips, foreign_key: :game_id, primary_key: :id

  validates :game_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :box_art_url, presence: true

  # ransackで検索可能な属性を定義
  def self.ransackable_attributes(auth_object = nil)
    ["name"] 
  end

  # 


end

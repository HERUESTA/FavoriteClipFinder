class Game < ApplicationRecord
  has_many :clips, foreign_key: :game_id

  validates :game_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :box_art_url, presence: true

  def self.ransackable_attributes(auth_object = nil)
    [ "name" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "clips", "broadcaster" ]
  end
end

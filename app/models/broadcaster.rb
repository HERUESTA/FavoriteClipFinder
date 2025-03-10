  class Broadcaster < ApplicationRecord
  has_many :clips, dependent: :destroy
  has_many :follows, dependent: :destroy
  has_many :users, through: :follows

  validates :broadcaster_id, presence: true, uniqueness: true
  validates :broadcaster_name, presence: true, uniqueness: true
  validates :broadcaster_login, presence: true, uniqueness: true
  validates :profile_image_url, presence: true

  def self.ransackable_attributes(auth_object = nil)
    [ "broadcaster_login", "broadcaster_name" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "clips", "game" ]
  end
  end

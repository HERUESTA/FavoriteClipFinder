class Streamer < ApplicationRecord
  has_many :clips, dependent: :destroy

  validates :streamer_id, presence: true, uniqueness: true
  validates :streamer_name, presence: true, uniqueness: true
  validates :display_name, presence: true, uniqueness: true
  validates :profile_image_url, presence: true
end

# app/models/streamer.rb

class Streamer < ApplicationRecord
  has_many :clips, foreign_key: :streamer_id, primary_key: :streamer_id

  validates :streamer_id, presence: true, uniqueness: true, format: { with: /\A\d+\z/, message: "must be numerical" }
  validates :streamer_name, presence: true
end

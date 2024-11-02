# app/models/clip.rb

class Clip < ApplicationRecord
  belongs_to :streamer
  belongs_to :game, optional: false # Game は必須とする

  validates :clip_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :language, presence: true
  validates :clip_created_at, presence: true
  validates :thumbnail_url, presence: true
  validates :duration, presence: true
  validates :view_count, presence: true
  # 他の必要なバリデーションを追加
end

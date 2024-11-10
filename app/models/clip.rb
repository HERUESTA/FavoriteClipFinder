class Clip < ApplicationRecord
  belongs_to :streamer, foreign_key: :streamer_id
  belongs_to :game, foreign_key: :game_id

  validates :clip_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :language, presence: true
  validates :clip_created_at, presence: true
  validates :thumbnail_url, presence: true
  validates :duration, presence: true
  validates :view_count, presence: true
  validates :creator_name, presence: true

  # ゲームに関するクリップを取得(最大60件)
  def self.get_game_clips(game_ids)
    where(game_id: game_ids)
      .includes(:streamer, :game)
      .order(clip_created_at: :desc)
      .limit(60)
  end

  # 配信者に関連するクリップを取得
  def self.get_streamer_clips(streamer_ids)
    where(streamer_id: streamer_ids)
      .includes(:streamer, :game)
      .order(clip_created_at: :desc)
      .limit(60)
  end
end

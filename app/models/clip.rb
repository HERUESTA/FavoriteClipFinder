class Clip < ApplicationRecord
  belongs_to :streamer, foreign_key: :streamer_id, primary_key: :streamer_id
  belongs_to :game, foreign_key: :game_id, primary_key: :game_id
  has_many :playlist_clips, dependent: :destroy
  has_many :playlists, through: :playlist_clips

  validates :clip_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :language, presence: true
  validates :clip_created_at, presence: true
  validates :thumbnail_url, presence: true
  validates :duration, presence: true
  validates :view_count, presence: true
  validates :creator_name, presence: true

# Ransackで検索可能な属性を定義
def self.ransackable_attributes(auth_object = nil)
  %w[clip_id title creator_name created_at clip_created_at duration view_count]
end

    # ransackで検索可能な関連付けを定義
    def self.ransackable_associations(auth_object = nil)
      %w[streamer game]
    end
  # ゲームに関するクリップを取得
  def self.get_game_clips(game_ids)
    where(game_id: game_ids)
      .includes(:streamer, :game)
      .order(clip_created_at: :desc)
  end

  # 配信者に関連するクリップを取得
  def self.get_streamer_clips(streamer_ids)
    where(streamer_id: streamer_ids)
      .includes(:streamer, :game)
      .order(clip_created_at: :desc)
  end

  # ゲームIDを定数として定義
  GAME_ID = {
    GTA: 32982,
    APEX: 511224,
    SF6: 55453844,
    VALORANT: 516575,
    LOL: 21779
  }.freeze

  # 最新のクリップを取得するスコープ
  scope :latest, ->(limit = 6) { order(clip_created_at: :desc).limit(limit) }


  # 特定のゲームの最新クリップを取得するスコープ
  scope :for_game, ->(game_id, limit = 6) { where(game_id: game_id).latest(limit).preload(:game, :streamer) }
end

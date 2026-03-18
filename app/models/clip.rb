class Clip < ApplicationRecord
  belongs_to :broadcaster, foreign_key: :broadcaster_id, primary_key: :broadcaster_id
  belongs_to :game, foreign_key: :game_id, primary_key: :game_id
  has_many :playlist_clips, dependent: :destroy
  has_many :playlists, through: :playlist_clips

  validates :clip_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :clip_created_at, presence: true
  validates :thumbnail_url, presence: true
  validates :view_count, presence: true
  validates :creator_name, presence: true


  scope :latest, ->(limit = 6) { order(clip_created_at: :desc).limit(limit) }
  scope :for_game, ->(game_id, limit = 6) { where(game_id: game_id).latest(limit).eager_load(:game, :broadcaster) }

  def self.ransackable_attributes(auth_object = nil)
    %w[clip_id title creator_name created_at clip_created_at duration view_count]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[broadcaster game]
  end

  GAME_ID = {
    GTA: 32982,
    APEX: 511224,
    SF6: 55453844,
    VALORANT: 516575,
    LOL: 21779
  }.freeze
end

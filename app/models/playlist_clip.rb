class PlaylistClip < ApplicationRecord
  belongs_to :playlist
  belongs_to :clip

  default_scope { order(:position) }

  validates :playlist_id, presence: true
  validates :clip_id, presence: true
  validates :position, numericality: { only_integer: true }, allow_nil: true
  validates :clip_id, uniqueness: { scope: :playlist_id }
end

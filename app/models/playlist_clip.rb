class PlaylistClip < ApplicationRecord
  # 関連付け
  belongs_to :playlist
  belongs_to :clip

  # 並び替えのためのデフォルトスコープ
  default_scope { order(:position) }

  # バリデーション
  validates :playlist_id, presence: true
  validates :clip_id, presence: true
  validates :position, numericality: { only_integer: true }, allow_nil: true

  # 一意性のバリデーション
  validates :clip_id, uniqueness: { scope: :playlist_id }

  
end

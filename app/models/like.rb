class Like < ApplicationRecord
  belongs_to :user, foreign_key: "user_uid", primary_key: "uid"
  belongs_to :playlist
  counter_culture :playlist

  validates :user_uid, presence: true
  validates :playlist_id, presence: true
end

class Like < ApplicationRecord
  belongs_to :user, foreign_key: "user_uid", primary_key: "uid"
  belongs_to :playlist, counter_cache: true

  validates :user_uid, presence: true
  validates :playlist_id, presence: true
  validates :playlist_id, uniqueness: { scope: :user_uid, message: "は既にいいねされています。" }
end

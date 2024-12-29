class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :streamer

  # ユーザーと配信者の組み合わせが一意であることをバリデート
  validates :user_id, uniqueness: { scope: :streamer_id }
end

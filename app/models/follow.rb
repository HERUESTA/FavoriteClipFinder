class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :broadcaster

  # ユーザーと配信者の組み合わせが一意であることをバリデート
  validates :user_id, uniqueness: { scope: :broadcaster_id }
end

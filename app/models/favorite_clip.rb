class FavoriteClip < ApplicationRecord
  # 関連付け
  belongs_to :user, foreign_key: "user_uid"
  belongs_to :clip


    # バリデーション
    validates :user_uid, presence: true
    validates :clip_id, presence: true

    # 一意性のバリデーション
    validates :clip_id, uniqueness: { scope: :user_uid }
end

class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :broadcaster

  validates :user_id, uniqueness: { scope: :broadcaster_id }
end

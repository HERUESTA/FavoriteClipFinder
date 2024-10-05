class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :registerable, :recoverable, :rememberable,
         :omniauthable, omniauth_providers: [ :twitch ]

  # Deviseがemailやpasswordのバリデーションを矯正しないようにする
  def email_required?
    false
  end

  def email_changed?
    false
  end

  def will_save_change_to_email?
    false
  end

  def password_required?
    false
  end

  # uidを元にユーザーを検索
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.user_name = auth.info.name
      user.profile_image_url = auth.info.image
    end
  end
end

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :omniauthable, omniauth_providers: [ :twitch ]

  # uidを元にユーザーを検索
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.user_name = auth.info.name
      user.email = auth.info.email if auth.info.email.present? # Twitchのemailがあれば保存
      user.profile_image_url = auth.info.image
    end
  end
end

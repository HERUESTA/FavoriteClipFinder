class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :omniauthable, omniauth_providers: [ :twitch ]

  # uidを元にユーザーを検索
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.user_name = auth.info.name
      user.email = auth.info.email if auth.info.email.present? # Twitchのemailがあれば保存
      user.profile_image_url = auth.info.image
      Rails.logger.debug "アクセストークン取得成功: #{user.profile_image_url}"

      # アクセストークン、リフレッシュトークン、有効期限を保存
      user.access_token = auth.credentials.token
      user.refresh_token = auth.credentials.refresh_token
      user.token_expires_at = Time.at(auth.credentials.expires_at) if auth.credentials.expires
    end
  end
end

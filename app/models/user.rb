class User < ApplicationRecord
  # アソシエーション
  has_many :playlists, foreign_key: "user_uid", primary_key: "uid", dependent: :destroy
  has_many :favorite_clips, foreign_key: "user_uid", primary_key: "uid", dependent: :destroy
  has_many :favorited_clips, through: :favorite_clips, source: :clip
  has_many :likes, foreign_key: "user_uid", primary_key: "uid", dependent: :destroy
  has_many :liked_playlists, through: :likes, source: :playlist
  has_many :follows, dependent: :destroy
  has_many :streamers, through: :follows

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :omniauthable, omniauth_providers: [ :twitch ]

  before_validation :set_unique_uid, on: :create

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  VALID_PASSWORD_REGEX = /\A(?=.*[a-z])(?=.*\d)[a-z\d]{8,75}\z/i
  validates :user_name,
  uniqueness: { case_sensitive: :false },
  length: { minimum: 4, maximum: 20 }
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX, message: "を○○@○○.○○の形式で入力して下さい" }, length: { maximum: 255 }
  validates :password, presence: true, length: { in: 8..75 }, format: { with: VALID_PASSWORD_REGEX, message: "を半角英数字8文字以上で入力して下さい" }
  validates_confirmation_of :password, message: "とパスワードの確認が一致しません"

  # uidを元にユーザーを検索または作成し、トークンがない場合や期限が切れている場合は更新
  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_create! do |u|
      u.user_name = auth.info.name
      u.email = auth.info.email
      u.profile_image_url = auth.info.image
      u.provider = auth.provider
      u.password = SecureRandom.alphanumeric(10)
    end

    # ユーザーが新規作成された場合、トークン情報を保存
    if user.access_token.nil? || user.token_expires_at.nil? || user.token_expires_at < Time.current
      Rails.logger.debug "トークンが無効または期限切れ、再取得を行います。"
      user.access_token = auth.credentials.token
      user.refresh_token = auth.credentials.refresh_token
      user.token_expires_at = Time.at(auth.credentials.expires_at) if auth.credentials.expires
      user.password = SecureRandom.alphanumeric(10)
      user.save!
    else
      Rails.logger.debug "有効なアクセストークンが既に存在します。"
    end
    user
  end

  # Twitch認証でない場合、uidを生成
  def set_unique_uid
    self.uid = generate_unique_uid if uid.blank?
  end

  def generate_unique_uid
    loop do
      new_uid = SecureRandom.uuid
      break new_uid unless User.exists?(uid: new_uid)
    end
  end
end

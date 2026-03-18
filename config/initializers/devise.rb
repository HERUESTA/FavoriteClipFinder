
Devise.setup do |config|
  config.mailer_sender = "please-change-me-at-config-initializers-devise@example.com"

  require "devise/orm/active_record"

  config.skip_session_storage = [ :http_auth ]

  config.authentication_keys = [ :user_name ]

  config.case_insensitive_keys = [ :user_name ]

  config.strip_whitespace_keys = [ :user_name ]

  config.stretches = Rails.env.test? ? 1 : 12

  config.reconfirmable = true

  config.expire_all_remember_me_on_sign_out = true

  config.password_length = 6..128

  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  config.reset_password_within = 6.hours

  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other

  # OmniAuth設定
  config.omniauth :twitch, ENV["TWITCH_CLIENT_ID"], ENV["TWITCH_CLIENT_SECRET"], scope: "user:read:follows"

  # OmniAuthでPOSTリクエストを許可
  OmniAuth.config.allowed_request_methods = [ :post ]
end

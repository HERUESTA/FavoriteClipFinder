OmniAuth.config.test_mode = true

OmniAuth.config.mock_auth[:twitch] = OmniAuth::AuthHash.new(
  provider: 'twitch',
  uid: "uid_#{SecureRandom.uuid}",
  info: {
    name: "name_#{SecureRandom.uuid}",
    email: "example@example.com"
  }
)

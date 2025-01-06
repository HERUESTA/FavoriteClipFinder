FactoryBot.define do
  factory :user do
    sequence(:uid) { |n| "uid#{n}" }
    sequence(:user_name) { |n| "user_name#{n}" }
    profile_image_url { nil }
    provider { nil }
    access_token { nil }
    refresh_token { nil }
    token_expires_at { nil }
    email { nil }
  end

  # Twitchユーザー
  trait :twitch_user do
    uid { "625219161" }
    user_name { "siesta0905" }
    profile_image_url
  end
end

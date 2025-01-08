FactoryBot.define do
  factory :user do
    uid { SecureRandom.alphanumeric(6) }
    sequence(:user_name) { |n| "user_#{n}" }
    sequence(:email) { |n| "user_#{n}@example.com" }
    password { "danson39" }
  end
end

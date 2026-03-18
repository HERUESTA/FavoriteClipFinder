FactoryBot.define do
  factory :user do
    sequence(:uid) { |n| "uid_#{n}" }
    sequence(:user_name) { |n| "user_#{n}" }
    sequence(:email) { |n| "user_#{n}@example.com" }
    password { "danson39" }
  end
end

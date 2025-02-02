FactoryBot.define do
  factory :broadcaster do
    sequence(:id) { |n| n }
    sequence(:broadcaster_id) { |n| "broadcaster_id_#{n}" }
    sequence(:broadcaster_login) { |n| "broadcaster_login_#{n}" }
    sequence(:broadcaster_name) { |n| "broadcaster_name_#{n}" }
    profile_image_url { "https://example.com/profile_image.jpg" }
  end
end

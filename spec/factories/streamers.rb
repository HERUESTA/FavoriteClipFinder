FactoryBot.define do
  factory :streamer do
    sequence(:id) { |n| n }
    sequence(:streamer_id) { |n| "streamer_id_#{n}" }
    sequence(:display_name) { |n| "display_name_#{n}" }
    sequence(:streamer_name) { |n| "streamer_name_#{n}" }
    profile_image_url { "https://example.com/profile_image.jpg" }
  end
end

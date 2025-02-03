FactoryBot.define do
  factory :clip do
    association :broadcaster
    association :game
    sequence(:clip_id) { |n| "clip_id_#{n}" }
    title { "title" }
    clip_created_at { Time.current }
    thumbnail_url { "https://example.com/thumbnail.jpg" }
    view_count { rand { 1..1000 } }
    creator_name { "creator_name" }
  end
end

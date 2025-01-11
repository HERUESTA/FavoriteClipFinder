FactoryBot.define do
  factory :game do
    sequence(:id) { |n| n }
    sequence(:game_id) { |n| "game_id_#{n}" }
    name { "Apex Legends" }
    box_art_url { "https://example.com/box_art.jpg" }
  end
end

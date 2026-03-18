FactoryBot.define do
  factory :playlist_clip do
    association :playlist
    association :clip
  end
end

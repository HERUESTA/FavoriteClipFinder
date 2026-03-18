FactoryBot.define do
  factory :like do
    association :user
    association :playlist
  end
end

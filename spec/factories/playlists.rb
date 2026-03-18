FactoryBot.define do
  factory :playlist do
    association :user
    sequence(:title, "title_1")
    visibility { "public" }
    likes_count { 0 }
  end
end

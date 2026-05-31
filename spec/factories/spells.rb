FactoryBot.define do
  factory :spell do
    title { FFaker::Name.unique.name }
    description { FFaker::Lorem.paragraph }

    trait :published do
      published_at { Time.current }
    end
  end
end

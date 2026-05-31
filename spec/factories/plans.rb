FactoryBot.define do
  factory :plan do
    title { FFaker::Name.unique.name }
    description { FFaker::Lorem.paragraph }
    level { 1 }

    trait :published do
      published_at { Time.current }
    end
  end
end

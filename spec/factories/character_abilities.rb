FactoryBot.define do
  factory :characteristic, aliases: [:character_ability] do
    title { FFaker::Name.unique.name }
    original_title { FFaker::Name.name }
    description { FFaker::Lorem.paragraph }

    trait :published do
      published_at { Time.current }
    end
  end
end

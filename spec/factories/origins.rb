FactoryBot.define do
  factory :origin do
    title { FFaker::Name.unique.name }
    description { FFaker::Lorem.paragraph }

    trait :house_heir do
      edition_source { :efota }
    end
  end
end

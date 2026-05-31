FactoryBot.define do
  factory :magic_item do
    title { FFaker::Name.unique.name }
    description { FFaker::Lorem.paragraph }
    category { :magic_item }
    rarity { :common }
    attunement { :unrequired }

    trait :published do
      published_at { Time.current }
    end
  end
end

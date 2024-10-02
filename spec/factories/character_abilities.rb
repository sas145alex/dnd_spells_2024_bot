FactoryBot.define do
  factory :character_ability do
    title { FFaker::Name.name }
    original_title { FFaker::Name.name }
    description { FFaker::Lorem.paragraph }
  end
end

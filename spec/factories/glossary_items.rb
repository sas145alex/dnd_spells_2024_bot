FactoryBot.define do
  factory :glossary_item do
    title { FFaker::Name.unique.name }
    description { FFaker::Lorem.paragraph }
    category { build(:glossary_category) }
  end
end

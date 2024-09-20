FactoryBot.define do
  factory :spell do
    title { FFaker::Name.unique.name }
    description { FFaker::Lorem.paragraph }
  end
end

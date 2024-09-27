FactoryBot.define do
  factory :tool do
    title { FFaker::Name.unique.name }
    description { FFaker::Lorem.paragraph }
  end
end

FactoryBot.define do
  factory :origin do
    title { FFaker::Name.unique.name }
    description { FFaker::Lorem.paragraph }
  end
end

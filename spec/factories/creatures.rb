FactoryBot.define do
  factory :creature do
    title { FFaker::Name.unique.name }
    description { FFaker::Lorem.paragraph }
  end
end

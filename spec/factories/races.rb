FactoryBot.define do
  factory :race do
    title { FFaker::Name.unique.name }
    description { "description" }
  end
end

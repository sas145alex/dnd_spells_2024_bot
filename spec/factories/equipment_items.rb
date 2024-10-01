FactoryBot.define do
  factory :equipment_item do
    title { FFaker::Name.unique.name }
    description { FFaker::Lorem.paragraph }
  end
end

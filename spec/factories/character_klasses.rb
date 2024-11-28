FactoryBot.define do
  factory :character_klass do
    title { FFaker::Name.unique.name }
    description { FFaker::Lorem.sentence }
  end
end

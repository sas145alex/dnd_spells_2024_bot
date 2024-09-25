FactoryBot.define do
  factory :feat do
    title { FFaker::Name.name }
    description { FFaker::Lorem.sentence }
    category { Feat.categories.keys.first }
  end
end

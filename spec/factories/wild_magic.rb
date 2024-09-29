FactoryBot.define do
  factory :wild_magic do
    description { FFaker::Lorem.paragraph }
    roll { 1..100 }
  end
end

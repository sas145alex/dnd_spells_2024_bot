FactoryBot.define do
  factory :mention do
    association :mentionable, factory: :spell
    association :another_mentionable, factory: :spell
  end
end

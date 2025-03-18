FactoryBot.define do
  factory :feedback do
    payload { {} }
    message { FFaker::Lorem.sentence }
  end
end

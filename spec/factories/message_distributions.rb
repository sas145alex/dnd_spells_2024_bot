FactoryBot.define do
  factory :message_distribution do
    title { FFaker::Name.name }
    content { FFaker::Lorem.paragraph }
  end
end

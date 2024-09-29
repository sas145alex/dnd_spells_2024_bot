FactoryBot.define do
  factory :bot_command do
    title { FFaker::Name.unique.name }
  end
end

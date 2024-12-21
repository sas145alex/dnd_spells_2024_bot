FactoryBot.define do
  factory :telegram_chat do
    sequence :external_id do |n|
      n
    end
  end
end

FactoryBot.define do
  factory :favorite do
    association :telegram_user
    association :favoritable, factory: :spell
  end
end

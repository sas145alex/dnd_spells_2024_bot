FactoryBot.define do
  factory :telegram_user do
    sequence :external_id do |n|
      n
    end

    trait :admin do
      admin { true }
    end
  end
end

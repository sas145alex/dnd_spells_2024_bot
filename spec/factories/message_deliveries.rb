FactoryBot.define do
  factory :message_delivery do
    message_distribution
    association :recipient, factory: :telegram_user
    external_id { recipient.external_id }
    status { "pending" }

    trait :sent do
      status { "sent" }
      sent_at { Time.current }
    end

    trait :failed do
      status { "failed" }
      error_reason { "blocked" }
    end
  end
end

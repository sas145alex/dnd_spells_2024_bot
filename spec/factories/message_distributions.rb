FactoryBot.define do
  factory :message_distribution do
    title { "MyString" }
    content { "MyText" }
    created_by { nil }
    updated_by { nil }
    last_sent_at { "2024-11-17 12:56:15" }
  end
end

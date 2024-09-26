FactoryBot.define do
  factory :glossary_item do
    title { "MyString" }
    original_title { "MyString" }
    description { "MyText" }
    category { nil }
    published_at { "2024-09-26 15:17:09" }
    created_by { nil }
    updated_by { nil }
  end
end

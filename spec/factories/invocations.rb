FactoryBot.define do
  factory :invocation do
    title { "MyString" }
    original_title { "MyString" }
    description { "MyText" }
    level { 1 }
    created_by { nil }
    updated_by { nil }
  end
end

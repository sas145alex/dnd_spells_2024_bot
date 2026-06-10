FactoryBot.define do
  factory :bastion do
    sequence(:title) { |n| "Bastion #{n}" }
    original_title { "Bastion EN" }
    description { "MyText" }
    original_description { "MyText EN" }
    category { :construction }
    level { 0 }
    created_by { nil }
    updated_by { nil }

    trait :published do
      published_at { Time.current }
    end

    trait :modification do
      category { :modification }
    end

    trait :leveling do
      category { :leveling }
      level { 5 }
    end
  end
end

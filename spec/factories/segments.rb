FactoryBot.define do
  factory :segment do
    association :resource, factory: :characteristic
    association :attribute_resource, factory: :characteristic
  end
end

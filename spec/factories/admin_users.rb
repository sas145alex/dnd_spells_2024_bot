FactoryBot.define do
  factory :admin_user do
    email { FFaker::Internet.email }
    password { SecureRandom.hex(6) }
  end
end

FactoryBot.define do
  factory :common_file do
    title { FFaker::Name.unique.name }

    after(:build) do |common_file|
      common_file.attachment.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/test_image.png")),
        filename: "test_image.png",
        content_type: "image/png"
      )
    end
  end
end

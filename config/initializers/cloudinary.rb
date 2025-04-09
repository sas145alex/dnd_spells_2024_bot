mock_url = "cloudinary://test1:test2@test3"
url = ENV["CLOUDINARY_URL"] || Rails.application.credentials.dig(:cloudinary, :url) || mock_url

Cloudinary.config_from_url(url)

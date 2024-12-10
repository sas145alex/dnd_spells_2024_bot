url = ENV.fetch("CLOUDINARY_URL")
unless Rails.env.production?
  delimeter = url.ends_with?("?") ? "" : "?"
  upload_prefix = "upload_prefix=#{Rails.env}"
  url = [url, delimeter, upload_prefix].join
end

Cloudinary.config_from_url(url)

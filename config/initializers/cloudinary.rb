url = ENV.fetch("CLOUDINARY_URL")

Cloudinary.config_from_url(url)

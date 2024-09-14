source "https://rubygems.org"

gem "rails", "~> 7.2.1"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"

gem "sprockets-rails"
gem "importmap-rails"
# gem "turbo-rails"
# gem "stimulus-rails"
gem "jbuilder"
gem "redis-rails"

gem "telegram-bot"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

gem "bootsnap", require: false

group :development, :test do
  gem 'dotenv'
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false
  gem "standard"
end

group :development do
  gem "web-console"
end

group :test do
end

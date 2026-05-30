source "https://rubygems.org"

# duplicate the value from .ruby-version file but kamal deploy process requires it's been specified in Gemfile also
ruby "4.0.5"

# Core
gem "rails", "~> 8.1"
gem "pg", "~> 1.1"
gem "puma", "~> 8.0"

# Asset pipeline & JS
gem "sprockets-rails", "~> 3.5"
gem "importmap-rails", "~> 2.2"
# gem "turbo-rails"
# gem "stimulus-rails"

# Admin UI, auth & styling
gem "activeadmin", "~> 3.4"
gem "activeadmin_addons", "~> 1.10"
gem "activeadmin_simplemde", "~> 1.3"
gem "devise", "~> 5.0"
gem "devise-i18n", "~> 1.15"
gem "sassc-rails", "~> 2.1"
gem "bootstrap-sass", "~> 3.4"
gem "active_bootstrap_skin", "~> 0.1"
gem "font-awesome-rails", "~> 4.7"
gem "rails-i18n", "~> 8.1"

# Bot & domain logic
gem "dry-initializer", "~> 3.2"
gem "telegram-bot", "~> 0.16"
gem "mutex_m", "~> 0.3"
gem "redcarpet", "~> 3.6"
gem "pg_search", "~> 2.3"
gem "draper", "~> 4.0"
gem "httparty", "~> 0.24"

# Monitoring & errors
gem "sentry-ruby", "~> 6.3"
gem "sentry-rails", "~> 6.3"
# Required in production for Sentry's profiler (config.profiles_sample_rate in config/initializers/sentry.rb)
gem "stackprof", "~> 0.2"

# Media / file storage
gem "cloudinary", "~> 2.4"
gem "active_storage_validations", "~> 3.0"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Boot performance
gem "bootsnap", "~> 1.22", require: false

# Solid stack (cache / queue / cable on Postgres)
gem "solid_cache", "~> 1.0"
gem "solid_queue", "~> 1.3"
gem "solid_cable", "~> 4.0"

# Deploy & APM
gem "kamal", "~> 2.10", require: false
gem "thruster", "~> 0.1", require: false
gem "newrelic_rpm", "~> 10.1"

group :development, :test do
  gem "rspec-rails", "~> 8.0"
  gem "factory_bot_rails", "~> 6.4"
  gem "ffaker", "~> 2.24"
  gem "observer", "~> 0.1" # for ffaker
  gem "timecop", "~> 0.9"
  gem "dotenv", "~> 3.1"
  gem "debug", "~> 1.11", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", "~> 8.0", require: false
end

group :development do
  gem "lefthook", "~> 2.1", require: false
  gem "rubocop-rails-omakase", "~> 1.1", require: false
  gem "rubocop-rails", "~> 2.34", require: false # already pulled by omakase; listed explicitly
  gem "web-console", "~> 4.3"
end

group :test do
  gem "database_cleaner-active_record", "~> 2.2"
  gem "test-prof", "~> 1.0"
  gem "webmock", "~> 3.23"
  gem "simplecov", "~> 0.22", require: false
end

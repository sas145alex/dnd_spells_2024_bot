source "https://rubygems.org"

ruby "3.4.2"
gem "rails", "~> 8.0.2"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"

gem "sprockets-rails"
gem "importmap-rails"
# gem "turbo-rails"
# gem "stimulus-rails"
gem "jbuilder", "~> 2.13"
gem "redis-rails"

gem "activeadmin"
gem "activeadmin_addons"
gem "activeadmin_simplemde"
gem "devise"
gem "devise-i18n"
gem "sassc-rails"
gem "bootstrap-sass"
gem "active_bootstrap_skin"
gem "font-awesome-rails"
gem "rails-i18n"

gem "dry-initializer"
gem "telegram-bot"
gem "mutex_m"
gem "redcarpet"
gem "pg_search"
gem "draper"
gem "httparty"

gem "sentry-ruby"
gem "sentry-rails"
gem "stackprof", "~> 0.2.26"

gem "cloudinary"
gem "active_storage_validations"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

gem "bootsnap", require: false

group :development, :test do
  gem "rspec-rails", "~> 7.0.0"
  gem "factory_bot_rails", "~> 6.4"
  gem "ffaker"
  gem "observer" # for ffaker
  gem "timecop"
  gem "dotenv", "~> 3.1"
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false
  gem "standard"
  gem "lefthook"
end

group :development do
  gem "rubocop-rails-omakase", require: false
  gem "web-console"
end

group :test do
  gem "database_cleaner-active_record"
  gem "test-prof", "~> 1.0"
  gem "webmock", "~> 3.23"
end

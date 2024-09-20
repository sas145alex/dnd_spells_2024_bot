source "https://rubygems.org"

ruby "3.3.4"
gem "rails", "~> 7.2.1"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"

gem "sprockets-rails"
gem "importmap-rails"
# gem "turbo-rails"
# gem "stimulus-rails"
gem "jbuilder"
gem "redis-rails"

gem "activeadmin"
gem "activeadmin_addons"
gem "activeadmin_simplemde"
gem "devise"
gem "sassc-rails"
gem "bootstrap-sass"
gem "active_bootstrap_skin"
gem "font-awesome-rails"

gem "telegram-bot"
gem "mutex_m"
gem "redcarpet"
gem "pg_search"
gem "draper"
gem "httparty"

gem "sentry-ruby"
gem "sentry-rails"
gem "stackprof"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

gem "bootsnap", require: false

group :development, :test do
  gem "rspec-rails", "~> 7.0.0"
  gem "factory_bot_rails"
  gem "ffaker"
  gem "observer" # for ffaker
  gem "timecop"
  gem "dotenv"
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false
  gem "standard"
end

group :development do
  gem "web-console"
end

group :test do
  gem "test-prof", "~> 1.0"
  gem "webmock"
end

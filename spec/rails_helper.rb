require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?
# Uncomment the line below in case you have `--require rails_helper` in the `.rspec` file
# that will avoid rails generators crashing because migrations haven't been run yet
# return unless Rails.env.test?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!

require "test_prof/recipes/rspec/let_it_be"
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  if Rails.env.development?
    # rake tasks
    nil
  else
    abort e.to_s.strip
  end
end

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
  # config.filter_gems_from_backtrace("gem name")

  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include ApiHelpers, type: :request

  config.before(:suite) do
    Rails.application.load_seed
    # Seeding runs model callbacks/concerns and would otherwise inflate the coverage report with
    # lines no spec actually exercises. Discard the seed-time hits so coverage reflects only what
    # the specs themselves run. Ruby's Coverage keeps tracking after a `clear: true` result.
    Coverage.result(stop: false, clear: true) if defined?(Coverage) && Coverage.running?
  end

  # issue after updating to new rails 8
  # https://github.com/heartcombo/devise/issues/5705#issuecomment-2442370072
  ActiveSupport.on_load(:action_mailer) do
    Rails.application.reload_routes_unless_loaded
  end
end

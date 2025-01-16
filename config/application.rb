require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if ['development', 'test'].include? ENV['RAILS_ENV']
  Dotenv::Rails.load
end

module FrStaffapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: ['assets', 'tasks'])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.i18n.load_path += Rails.root.glob('config/locales/**/*.{rb,yml}')
    config.i18n.default_locale = 'en-GB'

    if ENV['AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY'].present?
      config.middleware.use(
        ApplicationInsights::Rack::TrackRequest,
        ENV['AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY']
      )
    end
    config.exceptions_app = routes

    config.maintenance_enabled = ENV.fetch('MAINTENANCE_ENABLED', 'false').casecmp('true').zero?
    config.maintenance_allowed_ips = ENV.fetch('MAINTENANCE_ALLOWED_IPS', '').split(',').map(&:strip)
    config.maintenance_end = ENV.fetch('MAINTENANCE_END', nil)

    config.active_support.remove_deprecated_time_with_zone_name = true
    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time, ActiveSupport::HashWithIndifferentAccess]

  end
  WillPaginate.per_page = 20
end

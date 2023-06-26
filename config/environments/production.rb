require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = true

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true
  config.ssl_options = {
    hsts: { expires: 1.year, preload: true },
    redirect: { exclude: ->(request) { request.path.include?('submissions') } }
  }

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "fr_staffapp_production"

  config.action_mailer.perform_caching = false
  config.action_view.automatically_disable_submit_tag = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  #### FROM RAILS 6.0

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.assets.prefix = '/assets'

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = Uglifier.new(harmony: true)

  config.logstasher.enabled = true
  config.logstasher.suppress_app_log = true
  config.logstasher.log_level = Logger::INFO
  config.logstasher.logger_path = $stdout
  config.logstasher.source = 'logstasher'

  config.after_initialize do
    smtp_domain = ENV.fetch('SMTP_DOMAIN', 'localhost')

    ActionMailer::Base.default_url_options = {
      host: smtp_domain,
      protocol: ENV.fetch('SMTP_PROTOCOL', 'http')
    }
    ActionMailer::Base.default from: Settings.mail.from
    ActionMailer::Base.default reply_to: Settings.mail.reply_to
    ActionMailer::Base.smtp_settings = {
      address: ENV.fetch('SMTP_HOSTNAME', 'localhost'),
      port: ENV.fetch('SMTP_PORT', 587),
      domain: smtp_domain,
      user_name: ENV.fetch('SMTP_USERNAME', ''),
      password: ENV.fetch('SMTP_PASSWORD', ''),
      authentication: :login,
      enable_starttls_auto: true
    }
  end

end

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # SECURITY: fail closed.
  #
  # These two values cannot be defaulted safely. SECRET_KEY_BASE signs the
  # session cookie, so a missing value means either an unbootable app or -- far
  # worse -- a predictable key that lets anyone forge a session. DATABASE_URL
  # carries the database credentials; there is no safe fallback for it either.
  #
  # The check is explicit rather than left to a downstream framework error so
  # that the failure is loud, early and identical on every database adapter,
  # instead of surfacing as a confusing 500 on the first real request. See
  # todo/.env.example.
  %w[SECRET_KEY_BASE DATABASE_URL].each do |required_var|
    if ENV[required_var].to_s.strip.empty?
      raise "Refusing to boot in production: #{required_var} is not set. " \
            "Copy todo/.env.example and supply it via the environment."
    end
  end

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass
 
  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # Enabled so the deployed app fails closed rather than serving over plaintext.
  config.force_ssl = true

  # Log at :info in production; :debug leaks request internals and inflates
  # storage costs. Raise to :warn if log volume is a concern.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  # Structured JSON logging (see config/initializers/json_log_formatter.rb)
  # makes production logs machine-parseable for aggregation and alerting.
  config.log_formatter = JsonLogFormatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end

Vacaybug::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # default mailer
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address: "smtp.gmail.com",
    port: 587,
    domain: "gmail.com",
    authentication: "plain",
    enable_starttls_auto: true,
    user_name: "travelrank2014",
    password: "ranktravel2014"
  }

  # AWSAccessKeyId=AKIAJGKYDVCM3HA72JBQ
  # AWSSecretKey=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

  Paperclip.options[:command_path] = "/usr/local/bin/"
  config.paperclip_defaults = {
    :storage => :s3,
    :s3_credentials => {
      :bucket => 'vb-avatar-dev',
      :access_key_id => 'AKIAJGKYDVCM3HA72JBQ',
      :secret_access_key => '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'
    }
  }

  config.foursquare = {
    client_id: "KKO2PEWC5ZNO4K0UJRVOMQNW3NED5DEKHIO2XAOCSHJ4KKVL",
    client_secret: "ZULRBN0E4YQAWSHRYPZASZYMAKXNBHN5WAAXOXQRWMXOJEOO"
  }
end

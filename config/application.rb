require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EoshubIo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.urls = config_for(:urls)
    config.browserify_rails.commandline_options = "-t [ babelify --presets [ es2015 stage-0 ] --plugins [ syntax-async-functions transform-regenerator syntax-dynamic-import ] ]"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.assets.paths << Rails.root.join("vendor", "assets", "charting_library")
    # Disable asset cache
    config.assets.configure do |env|
      env.cache = ActiveSupport::Cache.lookup_store(:null_store)
    end
    config.assets.precompile += %w(charting_library/charting_library.min.js charting_library/static/*)
  end
end

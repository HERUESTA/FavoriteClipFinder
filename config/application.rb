require_relative "boot"

require "rails/all"

config.session_store :cookie_strore, key: "TwitchClipFinder"
Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    config.autoload_lib(ignore: %w[assets tasks])
  end
end

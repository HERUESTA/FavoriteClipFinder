require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module TwichClipFinder
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    config.session_store :cookie_store, key: "_twitch_clip_finder_session"

    config.autoload_lib(ignore: %w[assets tasks])
  end
end

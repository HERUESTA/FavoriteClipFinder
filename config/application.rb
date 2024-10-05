require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module TwichClipFinder
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Cookie設定
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

    config.autoload_lib(ignore: %w[assets tasks])
  end
end

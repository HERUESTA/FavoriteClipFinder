require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module TwichClipFinder
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Railsアプリケーションのデフォルトの言語設定を日本語に設定
    config.i18n.default_locale = :ja

    # Cookie設定
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

    # Active JobのキューアダプターをSolid_queueに設定
    config.active_job.queue_adapter = :solid_queue

    config.autoload_lib(ignore: %w[assets tasks])
  end
end

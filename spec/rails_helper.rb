# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# capybara等ファイルの読み込み設定
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }
# OmniAuthファイルの読み込み設定
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  config.use_transactional_fixtures = true

  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods

  # devise
  RSpec.configure do |config|
    config.include Warden::Test::Helpers
  end

  # テスト後にリセットが行われるようにする
  config.after :each do
    Warden.test_reset!
  end

  config.before(:each, type: :system) do
    driven_by :remote_chrome
    Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
    Capybara.server_port = 4444
    Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"
    Capybara.ignore_hidden_elements = false
  end
end

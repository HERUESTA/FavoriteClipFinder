# config/initializers/sidekiq.rb

require "sidekiq"
require "sidekiq-scheduler"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] }

  config.on(:startup) do
    # ダイナミックスケジューリングを有効化
    Sidekiq::Scheduler.dynamic = true

    # スケジュールファイルのパスを設定
    schedule_file = File.expand_path("../../sidekiq_schedule.yml", __FILE__)

    if File.exist?(schedule_file)
      # スケジュールファイルを読み込み、Sidekiq::Schedulerに設定
      Sidekiq.schedule = YAML.load_file(schedule_file)["scheduler"]["schedule"]
      Sidekiq::Scheduler.reload_schedule!

      # ログにスケジュールがロードされたことを出力
      Rails.logger.info "Sidekiq Scheduler loaded schedule from #{schedule_file}"
    else
      # スケジュールファイルが見つからない場合の警告ログ
      Rails.logger.warn "Sidekiq Scheduler schedule file not found: #{schedule_file}"
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"] }
end
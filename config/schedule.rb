# config/schedule.rb
set :environment, "development"
set :output, "log/cron_log.log"

every 1.day, at: "4:30 am" do
  runner "MyJobClass.perform_later"
end

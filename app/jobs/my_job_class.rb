# app/jobs/my_job_class.rb
class MyJobClass < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Hello from SolidQueue!"
    # ここにジョブの内容を記述
  end
end

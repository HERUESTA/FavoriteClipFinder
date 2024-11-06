class RemoveArgumentsFromSolidQueueJobs < ActiveRecord::Migration[7.2]
  def change
    remove_column :solid_queue_jobs, :arguments, :json
  end
end

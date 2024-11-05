class CreateSolidQueueJobs < ActiveRecord::Migration[7.2]
  def change
    create_table :solid_queue_jobs do |t|
      t.string :queue_name, null: false
      t.string :job_class, null: false
      t.json :arguments
      t.datetime :scheduled_at
      t.datetime :locked_at
      t.datetime :completed_at
      t.integer :retry_count, default: 0
      t.string :error_message

      t.timestamps
    end

    add_index :solid_queue_jobs, :queue_name
    add_index :solid_queue_jobs, :locked_at
    add_index :solid_queue_jobs, :completed_at
  end
end

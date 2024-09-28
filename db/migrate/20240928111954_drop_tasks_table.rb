class DropTasksTable < ActiveRecord::Migration[7.2]
  def up
    drop_table :tasks
  end

  def down
    create_table :tasks do |t|
      t.string :name
      t.timestamps
    end
  end
end

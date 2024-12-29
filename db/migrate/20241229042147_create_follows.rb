class CreateFollows < ActiveRecord::Migration[7.2]
  def change
    create_table :follows do |t|
      t.references :user, null: false, foreign_key: true
      t.references :streamer, null: false, foreign_key: true
      t.timestamps
    end

    add_index :follows, [:user_id, :streamer_id], unique: true
  end
end

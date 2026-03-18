class RemoveIndexToGame < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :clips, column: :game_id

    remove_index :games, :game_id

    remove_index :games, :name
  end
end

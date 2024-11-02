class AddGameIdToGames < ActiveRecord::Migration[7.2]
  def change
    add_column :games, :game_id, :string
    add_index :games, :game_id, unique: true
  end
end

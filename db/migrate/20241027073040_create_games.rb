class CreateGames < ActiveRecord::Migration[7.2]
  def change
    create_table :games do |t|
      t.string :name, null: false
      t.string :box_art_url
      t.timestamps
    end
    add_index :games, :name, unique: true
  end
end

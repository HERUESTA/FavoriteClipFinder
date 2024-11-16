class CreatePlaylists < ActiveRecord::Migration[7.2]
  def change
    create_table :playlists do |t|
      t.string :user_uid, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps

      t.index :user_uid
    end

    add_foreign_key :playlists, :users, column: :user_uid, primary_key: :uid
  end
end

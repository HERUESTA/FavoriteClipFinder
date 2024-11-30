class CreateLikes < ActiveRecord::Migration[7.2]
  def change
    create_table :likes do |t|
      t.string :user_uid, null: false
      t.references :playlist, null: false, foreign_key: true

      t.timestamps
    end

    add_index :likes, [ :user_uid, :playlist_id ], unique: true, name: "index_likes_on_user_uid_and_playlist_id"
  end
end

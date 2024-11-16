class CreateFavoriteClips < ActiveRecord::Migration[7.2]
  def change
    create_table :favorite_clips do |t|
      t.string :user_uid, null: false
      t.bigint :clip_id, null: false
      t.timestamps

      t.index [ :user_uid, :clip_id ], unique: true
    end

    add_foreign_key :favorite_clips, :users, column: :user_uid, primary_key: :uid
    add_foreign_key :favorite_clips, :clips
  end
end

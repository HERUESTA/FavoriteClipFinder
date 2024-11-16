class CreatePlaylistClips < ActiveRecord::Migration[7.2]
  def change
    create_table :playlist_clips do |t|
      t.bigint :playlist_id, null: false
      t.bigint :clip_id, null: false
      t.integer :position
      t.timestamps

      t.index [ :playlist_id, :clip_id ], unique: true
      t.index :clip_id
    end

    add_foreign_key :playlist_clips, :playlists
    add_foreign_key :playlist_clips, :clips
  end
end

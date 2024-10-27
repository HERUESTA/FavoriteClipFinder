class CreateClips < ActiveRecord::Migration[7.2]
  def change
    create_table :clips do |t|
      t.string :clip_id, null: false
      t.references :streamer, null: false, foreign_key: true, type: :bigint
      t.references :game, null: false, foreign_key: true, type: :bigint
      t.string :language
      t.string :title
      t.timestamp :clip_created_at
      t.string :thumbnail_url
      t.integer :duration
      t.integer :view_count
      t.timestamps
    end
    add_index :clips, :clip_id, unique: true
    add_index :clips, :clip_created_at
    add_index :clips, [ :game_id, :clip_created_at ]
  end
end

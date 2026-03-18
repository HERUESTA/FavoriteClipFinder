class RemoveIndexToClip < ActiveRecord::Migration[7.2]
  def change
    remove_index :clips, [ :game_id, :clip_created_at ]

    remove_index :clips, :game_id

    remove_index :clips, :streamer_id
  end
end

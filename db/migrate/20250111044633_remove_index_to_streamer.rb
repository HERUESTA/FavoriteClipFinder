class RemoveIndexToStreamer < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :clips, column: :streamer_id

    remove_index :streamers, :streamer_id

    remove_index :streamers, :streamer_name
  end
end

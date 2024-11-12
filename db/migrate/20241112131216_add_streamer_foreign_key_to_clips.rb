class AddStreamerForeignKeyToClips < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :clips, :streamers, column: :streamer_id, primary_key: :streamer_id
  end
end

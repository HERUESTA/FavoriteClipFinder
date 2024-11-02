
class ChangeStreamerIdInClipsToString < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :clips, :streamers
    remove_index :clips, :streamer_id
    change_column :clips, :streamer_id, :string
    add_index :clips, :streamer_id
  end
end

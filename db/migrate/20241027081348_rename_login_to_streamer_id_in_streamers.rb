class RenameLoginToStreamerIdInStreamers < ActiveRecord::Migration[7.2]
  def change
    rename_column :streamers, :login, :streamer_id
    rename_column :streamers, :display_name, :streamer_name
  end
end

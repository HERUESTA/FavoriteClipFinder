class AddIsWatchLaterToPlaylists < ActiveRecord::Migration[7.2]
  def change
    add_column :playlists, :is_watch_later, :boolean, default: false, null: false
  end
end

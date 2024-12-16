class AddLikesCountToPlaylistsCountCulture < ActiveRecord::Migration[7.2]
  def self.up
    add_column :playlists, :likes_count, :integer, null: false, default: 0
  end

  def self.down
    remove_column :playlists, :likes_count
  end
end

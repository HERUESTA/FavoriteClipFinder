class RemoveLikesFromPlaylists < ActiveRecord::Migration[7.2]
  def change
    remove_column :playlists, :likes, :integer
  end
end

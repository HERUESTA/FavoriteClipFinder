class RemoveLikesCountFromPlaylists < ActiveRecord::Migration[7.2]
  def change
    remove_column :playlists, :likes_count, :integer
  end
end

class AddLikesToPlaylists < ActiveRecord::Migration[7.2]
  def change
    add_column :playlists, :likes, :integer, default: 0, null: false
  end
end

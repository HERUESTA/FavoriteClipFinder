class RemoveDescriptionFromPlaylists < ActiveRecord::Migration[7.2]
  def change
    remove_column :playlists, :description, :text
  end
end

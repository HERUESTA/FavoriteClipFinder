class RenameNameToTitleInPlaylists < ActiveRecord::Migration[7.2]
  def change
    rename_column :playlists, :name, :title
  end
end

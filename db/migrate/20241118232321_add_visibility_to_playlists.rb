class AddVisibilityToPlaylists < ActiveRecord::Migration[7.2]
  def change
    add_column :playlists, :visibility, :string, default: "private", null: false
  end
end

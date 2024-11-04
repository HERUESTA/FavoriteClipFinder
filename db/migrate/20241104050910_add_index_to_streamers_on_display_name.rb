class AddIndexToStreamersOnDisplayName < ActiveRecord::Migration[7.2]
  def change
    add_index :streamers, "LOWER(display_name)", name: "index_streamers_on_lower_display_name"
  end
end

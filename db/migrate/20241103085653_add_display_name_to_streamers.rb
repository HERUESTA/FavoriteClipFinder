class AddDisplayNameToStreamers < ActiveRecord::Migration[7.2]
  def change
    add_column :streamers, :display_name, :string
  end
end

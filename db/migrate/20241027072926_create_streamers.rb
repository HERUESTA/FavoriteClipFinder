class CreateStreamers < ActiveRecord::Migration[7.2]
  def change
    create_table :streamers do |t|
      t.string :login, null: false
      t.string :display_name, null: false
      t.string :profile_image_url
      t.string :language
      t.timestamps
    end
    add_index :streamers, :login, unique: true
    add_index :streamers, :display_name
  end
end

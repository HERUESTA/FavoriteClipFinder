class RenameBroadcastersToStreamers < ActiveRecord::Migration[7.2]
  def change
    if table_exists?(:broadcasters) && !table_exists?(:streamers)
      rename_table :broadcasters, :streamers
    else
      puts "Skipping rename_table: 'broadcasters' does not exist or 'streamers' already exists."
    end
  end
end

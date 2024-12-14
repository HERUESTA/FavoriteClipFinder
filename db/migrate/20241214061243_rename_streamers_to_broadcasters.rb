class RenameStreamersToBroadcasters < ActiveRecord::Migration[7.2]
  def change
    if table_exists?(:streamers) && !table_exists?(:broadcasters)
      rename_table :streamers, :broadcasters
    else
      puts "Skipping rename_table: 'streamers' does not exist or 'broadcasters' already exists."
    end
  end
end

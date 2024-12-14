class RenameStreamersToBroadcasters < ActiveRecord::Migration[7.2]
  def change
    rename_table :streamers, :broadcasters
  end
end

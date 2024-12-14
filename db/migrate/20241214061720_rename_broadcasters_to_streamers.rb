class RenameBroadcastersToStreamers < ActiveRecord::Migration[7.2]
  def change
    rename_table :broadcasters, :streamers
  end
end

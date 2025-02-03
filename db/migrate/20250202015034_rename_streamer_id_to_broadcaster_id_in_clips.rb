class RenameStreamerIdToBroadcasterIdInClips < ActiveRecord::Migration[7.2]
  def change
    rename_column :clips, :streamer_id, :broadcaster_id
  end
end

class RenameStreamerIdToBroadcasterIdInFollows < ActiveRecord::Migration[7.2]
  def change
    # カラム名の変更
    rename_column :follows, :streamer_id, :broadcaster_id
  end
end

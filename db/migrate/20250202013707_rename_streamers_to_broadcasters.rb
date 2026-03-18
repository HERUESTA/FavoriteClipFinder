class RenameStreamersToBroadcasters < ActiveRecord::Migration[7.2]
  def change
    # テーブル名を変更
    rename_table :streamers, :broadcasters

    # カラム名を変更
    rename_column :broadcasters, :streamer_id, :broadcaster_id
    rename_column :broadcasters, :streamer_name, :broadcaster_name
    rename_column :broadcasters, :display_name, :broadcaster_login

    # display_nameのインデックスを削除して再作成
    remove_index :broadcasters, name: "index_streamers_on_lower_display_name"
  end
end

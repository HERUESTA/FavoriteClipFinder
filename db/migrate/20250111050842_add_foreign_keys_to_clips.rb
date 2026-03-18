class AddForeignKeysToClips < ActiveRecord::Migration[7.2]
  def change
    # streamer_id の外部キー制約を追加
    add_foreign_key :clips, :streamers, column: :streamer_id, primary_key: "streamer_id"

    # game_id の外部キー制約を追加
    add_foreign_key :clips, :games, column: :game_id, primary_key: "game_id"
  end
end

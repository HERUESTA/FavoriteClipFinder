class AddUniqueIndexesToStreamersAndGames < ActiveRecord::Migration[7.2]
  def change
    # streamers テーブルの streamer_id に一意インデックスを追加
    add_index :streamers, :streamer_id, unique: true

    # games テーブルの game_id に一意インデックスを追加
    add_index :games, :game_id, unique: true
  end
end

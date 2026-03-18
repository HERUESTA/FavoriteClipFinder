class AddForeignKeysAndIndexesToClips < ActiveRecord::Migration[7.2]
  def change
    # インデックスの追加
    add_index :clips, :broadcaster_id unless index_exists?(:clips, :broadcaster_id)
    add_index :clips, :game_id unless index_exists?(:clips, :game_id)

    # 外部キー制約の追加（すでに存在していなければ）
    unless foreign_key_exists?(:clips, :broadcasters, column: :broadcaster_id)
      add_foreign_key :clips, :broadcasters, column: :broadcaster_id, primary_key: "broadcaster_id"
    end

    unless foreign_key_exists?(:clips, :games, column: :game_id)
      add_foreign_key :clips, :games, column: :game_id, primary_key: "game_id"
    end
  end
end

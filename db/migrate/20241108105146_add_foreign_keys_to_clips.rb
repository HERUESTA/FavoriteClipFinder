class AddForeignKeysToClips < ActiveRecord::Migration[7.2]
  def change
    # 既存の外部キー制約を削除
    remove_foreign_key :clips, :games

    # game_id カラムの型を string に変更
    change_column :clips, :game_id, :string

    # 外部キー制約を再追加
    add_foreign_key :clips, :games, column: :game_id, primary_key: :game_id
  end
end

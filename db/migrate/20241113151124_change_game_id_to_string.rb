class ChangeGameIdToString < ActiveRecord::Migration[7.2]
  def up
    # 外部キー制約を削除
    remove_foreign_key :clips, :games if foreign_key_exists?(:clips, :games)

    # `games`テーブルと`clips`テーブルの`game_id`をstring型に変更
    change_column :games, :game_id, :string
    change_column :clips, :game_id, :string

    # 外部キー制約を再追加
    add_foreign_key :clips, :games, column: :game_id, primary_key: "game_id"
  end
end

class ChangeGamesIdToString < ActiveRecord::Migration[7.2]
  def change
    # `games`テーブルの`id`カラムをstring型に変更
    change_column :games, :id, :string
  end
end

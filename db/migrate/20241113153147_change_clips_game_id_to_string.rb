class ChangeClipsGameIdToString < ActiveRecord::Migration[7.2]
  def change
    # `clips`テーブルの`game_id`をstring型に変更
    change_column :clips, :game_id, :string
  end
end

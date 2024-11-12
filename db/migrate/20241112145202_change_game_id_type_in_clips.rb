class ChangeGameIdTypeInClips < ActiveRecord::Migration[7.2]
  def change
    change_column :clips, :game_id, :string
  end
end

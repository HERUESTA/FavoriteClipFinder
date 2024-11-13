class AddForeignKeyToClips < ActiveRecord::Migration[7.2]
  class AddForeignKeyToClips < ActiveRecord::Migration[6.0]
    def change
      add_foreign_key :clips, :games, column: :game_id, primary_key: "game_id"
    end
  end
end

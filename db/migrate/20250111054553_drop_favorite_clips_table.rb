class DropFavoriteClipsTable < ActiveRecord::Migration[7.2]
  def change
    # 外部キー制約を削除
    remove_foreign_key :favorite_clips, :clips
    remove_foreign_key :favorite_clips, column: :user_uid

    # favorite_clipsテーブルを削除
    drop_table :favorite_clips
  end
end

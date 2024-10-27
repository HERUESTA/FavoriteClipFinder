class RemoveLanguageFromClips < ActiveRecord::Migration[7.2]
  def change
    remove_column :clips, :language, :string
  end
end

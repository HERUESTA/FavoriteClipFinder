class AddLanguageToClips < ActiveRecord::Migration[7.2]
  def change
    add_column :clips, :language, :string
  end
end

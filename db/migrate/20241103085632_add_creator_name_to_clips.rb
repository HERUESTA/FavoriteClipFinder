class AddCreatorNameToClips < ActiveRecord::Migration[7.2]
  def change
    add_column :clips, :creator_name, :string
  end
end

class AddUserAndStreamerToFollows < ActiveRecord::Migration[7.2]
  def change
    add_reference :follows, :user, null: false, foreign_key: true
    add_reference :follows, :streamer, null: false, foreign_key: true
  end
end

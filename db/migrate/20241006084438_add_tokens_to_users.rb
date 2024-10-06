class AddTokensToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :access_token, :string
    add_column :users, :refresh_token, :string
    add_column :users, :token_expires_at, :datetime
  end
end

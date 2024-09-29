# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      ## Database authenticatable

      # カスタムカラム追加
      t.string :uid, null: false, default: ""
      t.string :user_name
      t.string :profile_image_url
      
      # t.string :email,              null: false, default: ""
      # t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      # t.string   :reset_password_token
      # t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :users, :uid, unique: true
    # add_index :users, :email,                unique: true
    # add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end
end
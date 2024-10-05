# app/controller/users_controller.rb
class UsersController < ApplicationController
  # TOPページに遷移
  def index
  end

  # 認証失敗のアクション
  def failure
    redirect_to root_path
  end
end

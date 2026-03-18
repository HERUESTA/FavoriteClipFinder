# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: [ :twitch ]

  def twitch
    @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
      else
        session["devise.twitch_data"] = auth.except("extra")
        redirect_to root_path
      end
  end

  def failure
    redirect_to root_path
  end
end

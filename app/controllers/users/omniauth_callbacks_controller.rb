# app/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: [ :twitch ]

  def twitch
    # OmniAuthから認証情報を取得
    # ログ出力
    Rails.logger.debug "Session ID before callback: #{session.id}"
    Rails.logger.debug "Session ID: #{session.id}"
    Rails.logger.debug "@userの前通ったよ！"

    @user = User.from_omniauth(request.env["omniauth.auth"])
    Rails.logger.debug "通ったよ！"

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Twitch") if is_navigational_format?
    else
      session["devise.twitch_data"] = request.env["omniauth.auth"].except("extra")
      redirect_to new_user_registration_url
    end
  end

  def failure
    Rails.logger.debug "OmniAuth State: #{request.params['state']}"
    Rails.logger.debug "Session ID in failure action: #{session.id}"
    redirect_to root_path
  end
end

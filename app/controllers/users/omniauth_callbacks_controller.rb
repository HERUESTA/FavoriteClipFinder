# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: [ :twitch ]

  def twitch
    # OmniAuthから認証情報を取得
    @user = User.from_omniauth(request.env["omniauth.auth"])
    code = params[:code] # 認証コード
    Rails.logger.debug "認証コード取得したよ！: #{code}"
    Rails.logger.debug "ユーザーのアクセストークン: #{@user.access_token}" if @user.access_token.present?

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Twitch") if is_navigational_format?
    else
      session["devise.twitch_data"] = auth.except("extra")
      redirect_to root_path
    end
  end

  def failure
    Rails.logger.debug "OmniAuth State: #{request.params['state']}"
    Rails.logger.debug "Session ID in failure action: #{session.id}"
    redirect_to root_path
  end
end

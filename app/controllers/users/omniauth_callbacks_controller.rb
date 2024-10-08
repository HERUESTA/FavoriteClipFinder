# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: [:twitch]

  def twitch
    # OmniAuthから認証情報を取得
    @user = User.from_omniauth(request.env["omniauth.auth"])
    code = params[:code] # 認証コード
    Rails.logger.debug "認証コード取得: #{code}"
    Rails.logger.debug "ユーザーのアクセストークン: #{@user.access_token}" if @user.access_token.present?

    if @user.persisted?
      # アクセストークンの有効期限を確認し、必要に応じてリフレッシュ
      refresh_access_token_if_needed(@user)

      # サインイン後のリダイレクト
      sign_in_and_redirect @user, event: :authentication
    else
      # 失敗時の処理
      session["devise.twitch_data"] = request.env["omniauth.auth"].except("extra")
      redirect_to root_path, alert: "認証に失敗しました。"
    end
  end

  def failure
    Rails.logger.debug "OmniAuth State: #{request.params['state']}"
    Rails.logger.debug "Session ID in failure action: #{session.id}"
    redirect_to root_path, alert: "認証に失敗しました。"
  end

  private

  # アクセストークンの有効期限を確認し、必要ならリフレッシュ
  def refresh_access_token_if_needed(user)
    if user.token_expires_at.present? && user.token_expires_at < Time.now
      Rails.logger.debug "アクセストークンが期限切れのため、リフレッシュを実行します。"
      refresh_access_token(user)
    else
      Rails.logger.debug "アクセストークンはまだ有効です。"
    end
  end

  # アクセストークンをリフレッシュするメソッド
  def refresh_access_token(user)
    if user.refresh_token.nil?
      Rails.logger.error "リフレッシュトークンが存在しません。再ログインが必要です。"
      redirect_to root_path, alert: "セッションが切れました。再度ログインしてください。" and return
    end

    response = Faraday.post("https://id.twitch.tv/oauth2/token") do |req|
      req.body = {
        client_id: ENV["TWITCH_CLIENT_ID"],
        client_secret: ENV["TWITCH_CLIENT_SECRET"],
        refresh_token: user.refresh_token,
        grant_type: "refresh_token"
      }
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"
    end

    if response.success?
      token_data = JSON.parse(response.body)
      user.update(
        access_token: token_data["access_token"],
        refresh_token: token_data["refresh_token"],
        token_expires_at: Time.now + token_data["expires_in"].to_i.seconds
      )
      Rails.logger.debug "アクセストークンのリフレッシュに成功しました。"
    else
      Rails.logger.error "アクセストークンのリフレッシュに失敗しました: #{response.body}"
      redirect_to root_path, alert: "アクセストークンの更新に失敗しました。" and return
    end
  end
end
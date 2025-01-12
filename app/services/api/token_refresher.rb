module Api
  class TokenRefresher
    def initialize(user)
      @user = user
    end

    def call
      return if @user.refresh_token.blank?

      response = Faraday.post("https://id.twitch.tv/oauth2/token") do |req|
        req.body = {
          client_id: ENV["TWITCH_CLIENT_ID"],
          client_secret: ENV["TWITCH_CLIENT_SECRET"],
          refresh_token: @user.refresh_token,
          grant_type: "refresh_token"
        }
        req.headers["Content-Type"] = "application/x-www-form-urlencoded"
      end

      if response.success?
        token_data = JSON.parse(response.body)
        @user.update!(
          access_token: token_data["access_token"],
          refresh_token: token_data["refresh_token"],
          token_expires_at: Time.current + token_data["expires_in"].to_i.seconds,
          password: SecureRandom.hex(8)
        )
        Rails.logger.debug "アクセストークンを更新しました。"
      else
        Rails.logger.error "アクセストークンの更新に失敗しました。: #{response.body}"
      end
    end
  end
end
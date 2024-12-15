class UsersController < ApplicationController
  after_action :set_followed_channels, only: [ :index ]
  def index
    if current_user.present?
      Rails.logger.debug "現在のユーザー: #{current_user}"
      # トークンの期限が存在し、期限が切れている場合はリフレッシュ
      if current_user.token_expires_at.present? && current_user.token_expires_at < Time.now
        refresh_access_token(current_user)
      end
    end
  end
end

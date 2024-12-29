class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_followed_channels
  before_action :set_search

  protected

  # deviseのストロングパラメータを設定する
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :user_name ])
  end

  def set_followed_channels
    if user_signed_in?
      # ログインしている場合は、そのユーザーのフォローリストを取得
      @followed_channels = current_user.follows.includes(:streamer).map(&:streamer)
    else
      @followed_channels = []
  
      # Twitch認証ユーザーのランダムなフォローリストを取得
      if Streamer.count > 0
        random_user = User.where(provider: "twitch").order("RANDOM()").first
        if random_user.present?
          @followed_channels = random_user.follows.includes(:streamer).map(&:streamer)
        end
      end
    end
  end

  # ransackのオブジェクトを生成する
  def set_search
    @q = Clip.includes(:streamer, :game).ransack(params[:q])
    @clips= @q.result(distinct: true).page(params[:page]).per(5)
  end
end

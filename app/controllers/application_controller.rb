class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_followed_channels
  before_action :set_search

  protected

  # deviseのストロングパラメータを設定する
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:user_name])
  end

  # フォローリストを取得するメソッド
  def set_followed_channels
    if user_signed_in?
      @followed_channels = current_user.follows.includes(:streamer).map(&:streamer)
    else
      @followed_channels = []
    end
  end

  # ransackのオブジェクトを生成する
  def set_search
    @q = Clip.includes(:streamer, :game).ransack(params[:q])
    @clips= @q.result(distinct: true).page(params[:page]).per(5)
  end
end

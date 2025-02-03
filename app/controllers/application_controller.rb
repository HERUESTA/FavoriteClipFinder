class ApplicationController < ActionController::Base
  before_action :setting_strong_parameters_devise, if: :devise_controller?
  before_action :get_followed_channels
  before_action :set_ransack_object

  NO_FOLLOW_BROADCASTER = 0
  PER_PAGE = 5

  protected

  def setting_strong_parameters_devise
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :user_name ])
  end

  def get_followed_channels
    if user_signed_in?
      @followed_channels = current_user.follows.preload(:broadcaster).map(&:broadcaster)
      @follow_str = "フォローしているチャンネル"
      if @followed_channels.empty?
        get_random_followed_channel
      end
    else
      @followed_channels = []
      get_random_followed_channel
    end
  end

  def get_random_followed_channel
    @follow_str = "あなたにおすすめのチャンネル"
    if Broadcaster.count > NO_FOLLOW_BROADCASTER
      random_user = User.where(provider: "twitch").order("RANDOM()").first
      if random_user.present?
        @followed_channels = random_user.follows.preload(:broadcaster).map(&:broadcaster)
      end
    end
  end

  # Headerでsearch_form_forを使用しているため
  # 全てのアクションでRansack::Searchオブジェクトを生成するようにする
  def set_ransack_object
    @q = Clip.preload(:broadcaster, :game).ransack(params[:q])
    @clips= @q.result(distinct: true).page(params[:page]).per(PER_PAGE)
  end
end

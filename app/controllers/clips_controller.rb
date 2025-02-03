class ClipsController < ApplicationController
  before_action :set_search, except: :search

  # 追加
  def search
    broadcaster_results = Broadcaster.where("broadcaster_name ILIKE ?", "%#{params[:q]}%")
    game_results = Game.where("name ILIKE ?", "%#{params[:q]}%")
    combined_results = broadcastrer_results + game_results
    @result = Kaminari.paginate_array(combined_results).page(params[:page]).per(10)
    respond_to do |format|
      format.js
    end
  end
end

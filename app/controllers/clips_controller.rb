class ClipsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:search]
  before_action :set_ransack_object, except: :search

  def search
    broadcaster_results = Broadcaster.where("broadcaster_name ILIKE ?", "%#{params[:q]}%")
    game_results = Game.where("name ILIKE ?", "%#{params[:q]}%")
    combined_results = broadcaster_results + game_results
    @result = Kaminari.paginate_array(combined_results).page(params[:page]).per(10)
    respond_to do |format|
      format.js
    end
  end
end

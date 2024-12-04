# app/controllers/search_controller.rb
class SearchController < ApplicationController
  def index
    # ransack検索用の変数定義
    search_query = params[:q]
    Rails.logger.debug "Ransack Query: #{search_query.inspect}"

    # ゲームと配信者のクリップ検索を両方実行
    @games = Game.ransack(name_cont: search_query).result(distinct: true)
    @streamers = Streamer.ransack(streamer_name_or_display_name_cont: search_query).result(distinct: true)

    @clips = []

    # ゲームと配信者のクリップを取得
    game_ids = @games.pluck(:game_id)
    streamer_ids = @streamers.pluck(:streamer_id)

    @clips = Clip.get_game_clips(game_ids) + Clip.get_streamer_clips(streamer_ids)

    # 重複を排除してクリップを一意にする
    Rails.logger.debug "uniq適用前クリップ数: #{@clips.count}"
    @clips = @clips.uniq
    Rails.logger.debug "クリップの数: #{@clips.count}"
    @clips = Kaminari.paginate_array(@clips).page(params[:page]).per(60)

    # プレイリストを渡してあげる（ログインユーザーでない場合、空配列を返す）
    if user_signed_in?
      @playlists = current_user.playlists
    else
      @playlists = []
    end


    # 検索ワードを変数化する
    @search_query = search_query
  end
end

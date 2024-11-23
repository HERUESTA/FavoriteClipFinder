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
    # テスト
    game_ids = @games.pluck(:game_id)
    streamer_ids = @streamers.pluck(:streamer_id)

    @clips = Clip.get_game_clips(game_ids) + Clip.get_streamer_clips(streamer_ids)

    # 重複を排除してクリップを一意にする
    @clips = @clips.uniq
    @clips = Kaminari.paginate_array(@clips).page(params[:page]).per(60)
    @search_query = search_query

    # ビューにフラグを渡して、検索結果がゲームからか配信者からかを示す
    render partial: "search/clips", locals: { clips: @clips, search_query: @search_query }
  end
end

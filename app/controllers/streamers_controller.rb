# app/controllers/streamers_controller.rb

class StreamersController < ApplicationController
  def show
    search_name = params[:name]
    Rails.logger.debug "検索対象の配信者名: #{search_name}"

    # 配信者を検索（streamer_name または display_name）
    @streamer = Streamer.where('LOWER(streamer_name) = ? OR LOWER(display_name) = ?', search_name.downcase, search_name.downcase).first
    Rails.logger.debug "@streamer: #{@streamer.inspect}"

    if @streamer
      # ページネーションを適用（1ページあたり20件）
      @clips = @streamer.clips.order(clip_created_at: :desc).page(params[:page]).per(20)
      Rails.logger.debug "@clips: #{@clips.inspect}"

      # 配信者情報をハッシュとして設定
      @streamer_info = { name: @streamer.streamer_name, display_name: @streamer.display_name }
      Rails.logger.debug "@streamer_info: #{@streamer_info.inspect}"
    else
      # 配信者が見つからなかった場合の処理
      flash.now[:alert] = "配信者名「#{search_name}」に一致するデータが見つかりませんでした。"
      @clips = []
      @streamer_info = { name: search_name }
    end
  end
end

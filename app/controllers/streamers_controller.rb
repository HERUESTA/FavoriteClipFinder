# app/controllers/streamers_controller.rb

class StreamersController < ApplicationController
  def show
    search_name = params[:name]
    Rails.logger.debug "検索対象の配信者名: #{search_name}"

    # 配信者を検索（streamer_name または display_name）
    @streamer = Streamer.where("LOWER(streamer_name) = ? OR LOWER(display_name) = ?", search_name.downcase, search_name.downcase).first
    Rails.logger.debug "@streamer: #{@streamer.inspect}"

    if @streamer
      # ページネーションを適用（1ページあたり15件）
      streamer_id = @streamer.streamer_id
      Rails.logger.debug "使用しているstreamer_id: #{streamer_id}"

      # Clipモデルから指定されたstreamer_idに紐づくクリップを取得し、関連するstreamer情報も取得
      @clips = Clip.where(streamer_id: @streamer.streamer_id)
                   .includes(:streamer, :game) # streamerとgameをプリロード
                   .order(clip_created_at: :desc)
                   .page(params[:page])
                   .per(15)

      # プロフィール画像URLのプレースホルダを置き換える
      @clips.each do |clip|
        clip.streamer.profile_image_url = clip.streamer.profile_image_url.gsub("{width}x{height}", "100x100") if clip.streamer&.profile_image_url
      end

      Rails.logger.debug "@clips: #{@clips.map { |clip| { clip_id: clip.clip_id, streamer_image: clip.streamer.profile_image_url } }}"
      Rails.logger.debug "@clips: #{@clips.inspect}"

      # 配信者情報をハッシュとして設定
      @streamer_info = { name: @streamer.streamer_name, display_name: @streamer.display_name, profile_image_url: @streamer.profile_image_url }
      Rails.logger.debug "@streamer_info: #{@streamer_info.inspect}"
    else
      # 配信者が見つからなかった場合の処理
      flash.now[:alert] = "配信者名「#{search_name}」に一致するデータが見つかりませんでした。"
      @clips = []
      @streamer_info = { name: search_name }
    end
  end
end

# app/services/twitch_client.rb

require "faraday"
require "json"

class TwitchClient
  BASE_URL = "https://api.twitch.tv/helix"

  def initialize
    @client_id = ENV["TWITCH_CLIENT_ID"]
    @access_token = ENV["TWITCH_ACCESS_TOKEN"]
    @connection = Faraday.new(url: BASE_URL) do |faraday|
      faraday.request :url_encoded
      faraday.response :logger, Rails.logger, bodies: true # デバッグ用
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter Faraday.default_adapter
    end
  end

  # ストリーマーのクリップを取得するメソッド
  # broadcaster_id: ストリーマーのTwitch ID（文字列）
  # max_results: 取得するクリップの最大数（デフォルトは20）
  def fetch_clips(broadcaster_id, max_results: 20)
    clips = []
    pagination = nil

    loop do
      params = {
        broadcaster_id: broadcaster_id,
        first: [ max_results - clips.size, 100 ].min # 最大100件まで一度に取得可能
      }
      params[:after] = pagination if pagination

      response = @connection.get("clips", params) do |req|
        req.headers["Client-ID"] = @client_id
        req.headers["Authorization"] = "Bearer #{@access_token}"
      end

      Rails.logger.debug "Received response status: #{response.status}"
      Rails.logger.debug "Received response headers: #{response.headers.inspect}"
      Rails.logger.debug "Received response body: #{response.body}"

      if response.success?
        data = response.body["data"]
        pagination = response.body["pagination"]["cursor"]
        clips += data
        break if clips.size >= max_results || pagination.nil?
      else
        Rails.logger.error "Twitch API Error: #{response.status} - #{response.body['message']}"
        break
      end
    end

    clips.first(max_results)
  rescue StandardError => e
    Rails.logger.error "TwitchClient Error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    []
  end

  # ゲーム情報を取得するメソッド
  # game_id: Twitch のゲーム ID（文字列）
  def fetch_game(game_id)
    response = @connection.get("games") do |req|
      req.params["id"] = game_id
      req.headers["Client-ID"] = @client_id
      req.headers["Authorization"] = "Bearer #{@access_token}"
    end

    Rails.logger.debug "Received game response status: #{response.status}"
    Rails.logger.debug "Received game response body: #{response.body}"

    if response.success? && response.body["data"].is_a?(Array) && !response.body["data"].empty?
      response.body["data"].first
    else
      Rails.logger.error "Failed to fetch game with ID #{game_id}: #{response.body['message']}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "TwitchClient fetch_game Error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    nil
  end
end

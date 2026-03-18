class TwitchClient
  BASE_URL = "https://api.twitch.tv/helix"
  MAX = 50
  MAX_CLIP_COUNT = 100
  MINIMAM_CLIP_COUNT = 0

  def initialize
    @client_id = ENV["TWITCH_CLIENT_ID"]
    @client_secret = ENV["TWITCH_CLIENT_SECRET"]
    @access_token = fetch_access_token
    @connection = Faraday.new(url: BASE_URL) do |faraday|
      faraday.request :url_encoded
      faraday.response :logger, Rails.logger, bodies: true # デバッグ用
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter Faraday.default_adapter
    end
  end

  def fetch_access_token
    Rails.cache.fetch("twitch_access_token", expires_in: 50.minutes) do
      uri = URI("https://id.twitch.tv/oauth2/token")
      params = {
        client_id:     @client_id,
        client_secret: @client_secret,
        grant_type:    "client_credentials"
      }
      response = Net::HTTP.post_form(uri, params)
      data = JSON.parse(response.body)
      data["access_token"]
    end
  rescue StandardError => e
    Rails.logger.error "Failed to fetch access token: #{e.message}"
    nil
  end

  def fetch_follower_count(broadcaster_id)
    response = @connection.get("channels/followers") do |req|
      req.params["broadcaster_id"] = broadcaster_id
      req.headers["Client-ID"] = @client_id
      req.headers["Authorization"] = "Bearer #{@access_token}"
    end

    if response.success?
      total_followers = response.body["total"]
      Rails.logger.debug "Total followers for broadcaster ID #{broadcaster_id}: #{total_followers}"
      total_followers
    else
      Rails.logger.error "Failed to fetch follower count for broadcaster ID #{broadcaster_id}: #{response.body['message']}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "Error fetching follower count: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    nil
  end

  def fetch_japanese_broadcasters(max_results: MAX)
    broadcasters = []
    pagination = nil

    loop do
      remaining = max_results - broadcasters.size
      break if remaining <= MINIMAM_CLIP_COUNT

      params = {
        first: [ remaining, MAX_CLIP_COUNT ].min,  # 最大100件ずつ取得
        language: "ja"
      }
      params[:after] = pagination if pagination

      response = @connection.get("streams", params) do |req|
        req.headers["Client-ID"] = @client_id
        req.headers["Authorization"] = "Bearer #{@access_token}"
      end

      if response.success?
        data = response.body["data"]
        broadcasters += data
        pagination = response.body["pagination"]["cursor"]
        break if pagination.nil? || data.empty?
      else
        Rails.logger.error "Twitch API Error: #{response.status} - #{response.body['message']}"
        break
      end
    end

    broadcasters.first(max_results)
  rescue StandardError => e
    Rails.logger.error "TwitchClient Error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    []
  end

  def fetch_clips(broadcaster_id, max_results)
    clip = Clip.find_by(broadcaster_id: broadcaster_id)

    if clip.nil?
      fetch_200_clips(broadcaster_id, max_results)
    else
      fetch_day_clips(broadcaster_id)
    end
  end

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

  def fetch_user_profile(user_id)
    response = @connection.get("users") do |req|
      req.params["id"] = user_id
      req.headers["Client-ID"] = @client_id
      req.headers["Authorization"] = "Bearer #{@access_token}"
    end

    if response.success? && response.body["data"].is_a?(Array) && !response.body["data"].empty?
      response.body["data"].first
    else
      Rails.logger.error "Failed to fetch user profile for user ID #{user_id}: #{response.body['message']}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "Error fetching user profile: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    nil
  end

  private

  def fetch_200_clips(broadcaster_id, max_results)
    clips = []
    pagination = nil
    total_clips = MINIMAM_CLIP_COUNT
    retry_count = 0
    while (remaining = max_results - total_clips) > MINIMAM_CLIP_COUNT
      params = {
        broadcaster_id: broadcaster_id,
        first: [ remaining, MAX_CLIP_COUNT ].min
      }
      params[:after] = pagination if pagination

      begin
        response = @connection.get("clips", params) do |req|
          req.headers["Client-ID"] = @client_id
          req.headers["Authorization"] = "Bearer #{@access_token}"
        end

        if response.success?
          data = response.body["data"]
          Rails.logger.debug "取得したクリップ数: #{data.size}"

          clips += data
          total_clips += data.size

          pagination = response.body.dig("pagination", "cursor")
          break if pagination.nil? || data.empty?
          sleep(1)
        else
          Rails.logger.error "Twitch API Error: #{response.status} - #{response.body['message']}"
          if response.status == 429 # レート制限
            status_429
          else
            break
          end
        end
      # Faradayの接続エラーとタイムアウトエラーの例外処理
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
        # 失敗した場合、３回までトライする
        if retry_count < 3
          retry_count += 1
          sleep(2 ** retry_count)
          retry
        else
          Rails.logger.error "APIリクエスト失敗: #{e.message}"
          break
        end
      # Railsの標準的なエラーの例外処理
      rescue StandardError => e
        Rails.logger.error "Unexpected error: #{e.message}"
        break
      end
    end
    clips
  end

  def fetch_day_clips(broadcaster_id)
    clips = []
    retry_count = 0
    params = {
      broadcaster_id: broadcaster_id,
      first: 100,
      started_at: 1.day.ago.utc.iso8601,
      ended_at: Time.now.utc.iso8601
    }

    begin
      @response = perform_request(params)

      if @response.success?
        data = @response.body["data"]
        Rails.logger.debug "取得したクリップ数: #{data.size}"

        clips += data
      else
        if @response.status == 429 # レート制限
          status_429
        else
          return
        end
      end
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      if retry_count < 3
        retry_count += 1
        sleep(2 ** retry_count)
        retry
      else
        Rails.logger.error "APIリクエスト失敗: #{e.message}"
        return
      end
    rescue StandardError => e
      Rails.logger.error "Unexpected error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      return
    end
    clips
  end

  def perform_request(params)
    @connection.get("clips", params) do |req|
      req.headers["Client-ID"] = @client_id
      req.headers["Authorization"] = "Bearer #{@access_token}"
    end
  end

  def status_429
    reset_time = @response.headers["Ratelimit-Reset"].to_i
    sleep_time = reset_time - Time.now.to_i
    sleep(sleep_time) if sleep_time > 0
  end
end

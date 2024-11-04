# app/services/twitch_client.rb

class TwitchClient
  def initialize
    @client_id = ENV["TWITCH_CLIENT_ID"]
    @client_secret = ENV["TWITCH_CLIENT_SECRET"]
    @access_token = fetch_access_token
  end

  # アクセストークンを取得
  def fetch_access_token
    response = Faraday.post("https://id.twitch.tv/oauth2/token") do |req|
      req.body = {
        client_id: @client_id,
        client_secret: @client_secret,
        grant_type: "client_credentials"
      }
    end

    if response.status == 200
      JSON.parse(response.body)["access_token"]
    else
      Rails.logger.error "Failed to fetch Twitch access token: #{response.body}"
      nil
    end
  end

  # 日本の人気配信者を取得
  def fetch_popular_japanese_streamers(limit: 100, offset: 0)
    response = Faraday.get("https://api.twitch.tv/helix/streams") do |req|
      req.params["first"] = limit
      req.params["language"] = "ja"
      req.params["offset"] = offset
      req.headers["Client-ID"] = @client_id
      req.headers["Authorization"] = "Bearer #{@access_token}"
    end

    if response.status == 200
      JSON.parse(response.body)["data"]
    else
      Rails.logger.error "Failed to fetch popular Japanese streamers: #{response.body}"
      []
    end
  end

  # 配信者の情報を取得
  def fetch_streamer_info(streamer_id)
    response = Faraday.get("https://api.twitch.tv/helix/users") do |req|
      req.params["id"] = streamer_id
      req.headers["Client-ID"] = @client_id
      req.headers["Authorization"] = "Bearer #{@access_token}"
    end

    if response.status == 200
      JSON.parse(response.body)["data"].first
    else
      Rails.logger.error "Failed to fetch streamer info for #{streamer_id}: #{response.body}"
      nil
    end
  end

  # 特定の配信者のクリップを取得
  def fetch_clips(broadcaster_id, max_results: 100)
    response = Faraday.get("https://api.twitch.tv/helix/clips") do |req|
      req.params["broadcaster_id"] = broadcaster_id
      req.params["first"] = max_results
      req.headers["Client-ID"] = @client_id
      req.headers["Authorization"] = "Bearer #{@access_token}"
    end

    if response.status == 200
      JSON.parse(response.body)["data"]
    else
      Rails.logger.error "Failed to fetch clips for broadcaster_id #{broadcaster_id}: #{response.body}"
      []
    end
  end

  # 特定のゲーム情報を取得
  def fetch_game(game_id)
    response = Faraday.get("https://api.twitch.tv/helix/games") do |req|
      req.params["id"] = game_id
      req.headers["Client-ID"] = @client_id
      req.headers["Authorization"] = "Bearer #{@access_token}"
    end

    if response.status == 200
      JSON.parse(response.body)["data"].first
    else
      Rails.logger.error "Failed to fetch game info for game_id #{game_id}: #{response.body}"
      nil
    end
  end

  # ユーザー情報を取得
  def fetch_user_info(user_id)
    response = Faraday.get("https://api.twitch.tv/helix/users") do |req|
      req.params["id"] = user_id
      req.headers["Client-ID"] = @client_id
      req.headers["Authorization"] = "Bearer #{@access_token}"
    end

    if response.status == 200
      JSON.parse(response.body)["data"].first
    else
      Rails.logger.error "Failed to fetch user info for user_id #{user_id}: #{response.body}"
      nil
    end
  end
end

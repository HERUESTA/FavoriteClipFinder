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
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"
    end

    if response.status == 200
      JSON.parse(response.body)["access_token"]
    else
      Rails.logger.error "Failed to fetch Twitch access token: #{response.body}"
      nil
    end
  end

  # 配信者のクリップを取得
  def fetch_clips(streamer_twitch_id, max_results: 100)
    response = Faraday.get("https://api.twitch.tv/helix/clips") do |req|
      req.params["broadcaster_id"] = streamer_twitch_id
      req.params["first"] = max_results
      req.headers["Client-ID"] = @client_id
      req.headers["Authorization"] = "Bearer #{@access_token}"
    end

    if response.status == 200
      clips = JSON.parse(response.body)["data"]
      clips.map do |clip|
        {
          "id" => clip["id"],
          "title" => clip["title"],
          "game_id" => clip["game_id"],
          "language" => clip["language"],
          "created_at" => clip["created_at"],
          "thumbnail_url" => clip["thumbnail_url"],
          "duration" => clip["duration"],
          "view_count" => clip["view_count"],
          "creator_id" => clip["creator_id"],
          "creator_name" => clip["creator_name"]
        }
      end
    else
      Rails.logger.error "Failed to fetch clips for streamer #{streamer_twitch_id}: #{response.body}"
      []
    end
  end

  # ゲーム情報を取得
  def fetch_game(game_id)
    response = Faraday.get("https://api.twitch.tv/helix/games") do |req|
      req.params["id"] = game_id
      req.headers["Client-ID"] = @client_id
      req.headers["Authorization"] = "Bearer #{@access_token}"
    end

    if response.status == 200
      games = JSON.parse(response.body)["data"]
      games.first
    else
      Rails.logger.error "Failed to fetch game #{game_id}: #{response.body}"
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
      users = JSON.parse(response.body)["data"]
      users.first
    else
      Rails.logger.error "Failed to fetch user #{user_id}: #{response.body}"
      nil
    end
  end

  # 配信者情報を取得
  def fetch_streamer_info(streamer_twitch_id)
    response = Faraday.get("https://api.twitch.tv/helix/users") do |req|
      req.params["id"] = streamer_twitch_id
      req.headers["Client-ID"] = @client_id
      req.headers["Authorization"] = "Bearer #{@access_token}"
    end

    if response.status == 200
      users = JSON.parse(response.body)["data"]
      users.first
    else
      Rails.logger.error "Failed to fetch streamer info #{streamer_twitch_id}: #{response.body}"
      nil
    end
  end
end

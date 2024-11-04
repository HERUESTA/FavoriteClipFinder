# /myapp/app/services/twitch_client.rb

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
  def fetch_popular_japanese_streamers(limit: 100, cursor: nil)
    response = Faraday.get("https://api.twitch.tv/helix/streams") do |req|
      req.params["first"] = limit
      req.params["language"] = "ja"
      req.params["after"] = cursor if cursor.present?
      req.headers["Client-ID"] = @client_id
      req.headers["Authorization"] = "Bearer #{@access_token}"
    end

    if response.status == 200
      data = JSON.parse(response.body)
      streamers = data["data"]
      next_cursor = data.dig("pagination", "cursor")
      [streamers, next_cursor]
    else
      Rails.logger.error "Failed to fetch popular Japanese streamers: #{response.body}"
      [[], nil]
    end
  end
end
# app/services/twitch_client.rb

class TwitchClient
  def initialize
    @client_id = ENV["TWITCH_CLIENT_ID"]
    @client_secret = ENV["TWITCH_CLIENT_SECRET"]
    @access_token = fetch_access_token
  end

  # アクセストークンを取得するメソッド
  def fetch_access_token
    response = Faraday.post("https://id.twitch.tv/oauth2/token") do |req|
      req.body = {
        client_id: @client_id,
        client_secret: @client_secret,
        grant_type: "client_credentials"
      }
    end
    JSON.parse(response.body)["access_token"] if response.status == 200
  end

  # 日本の人気配信者を取得するメソッド
  def fetch_popular_japanese_streamers(limit: 300)
    streamer_data = []
    cursor = nil

    while streamer_data.size < limit
      response = Faraday.get("https://api.twitch.tv/helix/streams") do |req|
        req.params["first"] = 100
        req.params["language"] = "ja"
        req.params["after"] = cursor if cursor
        req.headers["Client-ID"] = @client_id
        req.headers["Authorization"] = "Bearer #{@access_token}"
      end

      data = JSON.parse(response.body)["data"]
      break if data.empty?

      streamer_data.concat(data)
      cursor = JSON.parse(response.body)["pagination"]["cursor"]
      break if streamer_data.size >= limit
    end

    streamer_data.take(limit)  # 指定した数だけ返す
  end
end
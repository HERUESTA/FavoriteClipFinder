class FetchJapaneseStreamersJob < ApplicationJob
  queue_as :default

  def perform
    client = TwitchClient.new
    streamers = client.fetch_japanese_streamers(max_results: 50)  # 1回の実行で最大50件

    streamers.each do |data|
      # フォロワー数を取得
      follower_count = client.fetch_follower_count(data["user_id"])
      next if follower_count.nil? || follower_count < 12_000  # 12,000人未満はスキップ

      save_streamer(data, client)
    end
  end

  private

  def save_streamer(data, client)
    # プロフィール情報を取得
    user_data = client.fetch_user_profile(data["user_id"])
    return if user_data.nil?  # プロフィール情報が取得できなかった場合はスキップ

    streamer = Streamer.find_or_initialize_by(streamer_id: data["user_id"])
    streamer.display_name = data["user_name"]
    streamer.streamer_name = data["user_login"]
    streamer.profile_image_url = user_data["profile_image_url"]
    streamer.save!
  rescue StandardError => e
    Rails.logger.error "Failed to save streamer #{data['user_name']}: #{e.message}"
  end
end

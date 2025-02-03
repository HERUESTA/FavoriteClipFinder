class FetchJapaneseBroadcastersJob < ApplicationJob
  queue_as :default

  def perform
    client = TwitchClient.new
    broadcasters = client.fetch_japanese_broadcasters(max_results: 50)  # 1回の実行で最大50件

    broadcasters.each do |data|
      # フォロワー数を取得
      follower_count = client.fetch_follower_count(data["user_id"])
      next if follower_count.nil? || follower_count < 40000  # 40,000人未満はスキップ

      save_broadcaster(data, client)
    end
  end

  private

  def save_broadcaster(data, client)
    # プロフィール情報を取得
    user_data = client.fetch_user_profile(data["user_id"])
    return if user_data.nil?  # プロフィール情報が取得できなかった場合はスキップ

    broadcaster = Broadcaster.find_or_initialize_by(broadcaster_id: data["user_id"])
    broadcaster.broadcaster_name = data["user_name"]
    broadcaster.broadcaster_login = data["user_login"]
    broadcaster.profile_image_url = user_data["profile_image_url"]
    broadcaster.save!
  rescue StandardError => e
    Rails.logger.error "配信者の保存に失敗しました。 #{data['user_name']}: #{e.message}"
  end
end

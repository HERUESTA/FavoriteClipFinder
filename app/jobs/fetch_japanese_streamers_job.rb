# app/jobs/fetch_japanese_streamers_job.rb

class FetchJapaneseStreamersJob < ApplicationJob
  queue_as :default

  def perform
    client = TwitchClient.new
    streamers = client.fetch_japanese_streamers

    streamers.each do |data|
      save_streamer(data)
    end
  end

  private

  def save_streamer(data)
    streamer = Streamer.find_or_initialize_by(streamer_id: data["user_id"])
    streamer.streamer_name = data["user_login"]
    streamer.display_name = data["user_name"]
    streamer.profile_image_url = data["thumbnail_url"]
    streamer.save!
  rescue StandardError => e
    Rails.logger.error "Failed to save streamer #{data['user_name']}: #{e.message}"
  end
end

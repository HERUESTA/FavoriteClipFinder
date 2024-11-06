# app/jobs/fetch_twitch_clips_job.rb

class FetchTwitchClipsJob < ApplicationJob
  queue_as :default

  def perform(streamer_id = nil)
    client = TwitchClient.new

    if streamer_id
      # 特定の配信者のクリップを取得
      fetch_and_save_clips(client, streamer_id)
    else
      # streamer_id が指定されていない場合、過去7日以内に配信を行った配信者を対象にジョブをキューに追加
      recent_streamers = Streamer.where("updated_at >= ?", 7.days.ago)

      recent_streamers.find_each do |streamer|
        FetchTwitchClipsJob.perform_later(streamer.streamer_id)
      end
    end
  end

  private

  def fetch_and_save_clips(client, streamer_id)
    streamer = Streamer.find_by(streamer_id: streamer_id)
    return unless streamer

    clips = client.fetch_clips(streamer_id, max_results: 10) # 件数を制限
    clips.each do |clip_data|
      save_clip(clip_data, streamer)
    end
  end

  def save_clip(clip_data, streamer)
    clip = Clip.find_or_initialize_by(clip_id: clip_data["id"])

    clip.attributes = {
      clip_id: clip_data["id"],
      streamer_id: streamer.streamer_id,
      game_id: clip_data["game_id"] || 0,
      title: clip_data["title"],
      language: clip_data["language"],
      creator_name: clip_data["creator_name"],
      clip_created_at: clip_data["created_at"],
      thumbnail_url: clip_data["thumbnail_url"],
      duration: clip_data["duration"].to_i,
      view_count: clip_data["view_count"].to_i
    }

    clip.save!
  rescue StandardError => e
    Rails.logger.error "Failed to save clip ID #{clip_data['id']}: #{e.message}"
  end
end

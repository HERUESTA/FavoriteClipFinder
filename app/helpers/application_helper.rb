module ApplicationHelper
  def default_meta_tags
  playlist_title       = @playlist&.title.presence || "Twitchのクリップやプレイリストを共有できるサービス"
  playlist_image_url   = @playlist&.clips&.first&.thumbnail_url || image_url("ogp.jpg")

    {
      site: "TwitchClipFinder",
      title: "Twitchのクリップやプレイリストを共有できるサービス",
      reverse: true,
      charset: "utf-8",
      description: "TwitchClipFinderでは他者が作成したクリップやプレイリストを共有することができます",
      keywords: "Twitch,クリップ,ゲーム,ストリーマー,プレイリスト",
      canonical: request.original_url,
      separator: "|",
      og: {
        site_name: "TwitchClipFinder",
        title: "Twitchのクリップやプレイリストを共有できるサービス",
        description: "TwitchClipFinderでは他者が作成したクリップやプレイリストを共有することができます",
        type: "website",
        url: request.original_url,
        image: image_url("ogp.jpg"),
        locale: "ja-JP"
      },
      # Twitterカード設定
      twitter: {
      card:        "summary_large_image",
      site:        "@obvyamdrss",  # あなたのアカウント名に変更
      title:       playlist_title,
      image:       playlist_image_url
    }
    }
  end
end

module ApplicationHelper
  def default_meta_tags
    playlist_img = @playlist&.clips&.first&.thumbnail_url.presence || image_url("ogp.jpg")
    playlist_title = @playlist&.title.presence || "Twitchのクリップやプレイリストを共有できるサービス"
    {
      site: "FavoriteClipFinder",
      title: playlist_title,
      reverse: true,
      charset: "utf-8",
      description: "FavoriteClipFinderでは他者や自分が作成したTwitchのクリップやプレイリストを共有することができます",
      keywords: "Twitch,クリップ,ゲーム,ストリーマー,プレイリスト",
      canonical: request.original_url,
      separator: "|",
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: "website",
        url: request.original_url,
        image: playlist_img,
        local: "ja-JP"
      },
      twitter: {
        card: "summary_large_image",
        site: "@siesta985736",
        image: playlist_img
      }
    }
  end
end

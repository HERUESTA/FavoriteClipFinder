module ApplicationHelper
  def default_meta_tags
    {
      site: "FavoriteClipFinder",
      title: "Twitchのクリップやプレイリストを共有できるサービス",
      reverse: true,
      charset: "utf-8",
      description: "FavoriteClipFinderでは他者が作成したクリップやプレイリストを共有することができます",
      keywords: "Twitch,クリップ,ゲーム,ストリーマー,プレイリスト",
      canonical: request.original_url,
      separator: "|",
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: "website",
        url: request.original_url,
        image: image_url("ogp.jpg"),
        local: "ja-JP"
      },
      twitter: {
        card: "summary_large_image",
        site: "@siesta985736",
        image: image_url("ogp.jpg")
      }
    }
  end
end

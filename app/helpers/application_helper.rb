module ApplicationHelper
  def default_meta_tags
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
      twitter: {
        card: "summary_large_image",
        site: "@obvyamdrss",
        image: image_url("ogp.jpg")
      }
    }
  end

  def get_twitter_card_info(page)
    twitter_card = {}
    if page
      twitter_card[:url] = page.url
      twitter_card[:title] = @playlist.title
      twitter_card[:image] = @playlist.clips.first&.thumbnail_url
    else
      twitter_card[:url] = playlist_path(@playlist)
      twitter_card[:title] = "Webページ更新管理ツール「Moook」"
      twitter_card[:description] = "いつもの更新いつもの更新確認、Moookを使えばお気に入りのページの更新を見逃しません。"
      twitter_card[:image] = "https://raw.githubusercontent.com/Madogiwa0124/Moook/master/app/assets/images/favicon.png"
    end
    twitter_card[:card] = "summary"
    twitter_card[:site] = "@Madogiwa_Boy"
    twitter_card
  end
end

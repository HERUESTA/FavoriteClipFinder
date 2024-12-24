module ApplicationHelper
  def default_meta_tags
    # 動的情報の準備
    playlist_title       = @playlist&.title.presence || "Twitchのクリップやプレイリストを共有できるサービス"
    playlist_image_url   = @playlist&.clips&.first&.thumbnail_url || image_url("ogp.jpg")

    {
      site:        "TwitchClipFinder",
      title:       playlist_title,         # <title> タグ
      reverse:     true,
      charset:     "utf-8",
      keywords:    "Twitch,クリップ,ゲーム,ストリーマー,プレイリスト",
      canonical:   request.original_url,
      separator:   "|",

      # OGP 設定
      og: {
        site_name:   "TwitchClipFinder",
        title:       playlist_title,
        type:        "website",
        url:         request.original_url,

        # --- ポイント: 複数の画像を配列で指定 ---
        image: [
          image_url("ogp.jpg"),      # 静的な OGP 画像 (常に先頭に表示)
          playlist_image_url         # プレイリスト固有のサムネイル
        ],
        locale:      "ja-JP"
      },

      # Twitter カード設定
      twitter: {
        card:        "summary_large_image",
        site:        "@obvyamdrss",    # 変更してください
        title:       playlist_title,
        image:       playlist_image_url
      }
    }
  end
end
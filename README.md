TwitchClipFinder

サービス概要

Twitchの日本配信者のクリップを簡単に検索できるサービスです。配信者名、ゲーム名、日時でそれぞれ検索することができます。また、いいねすることによりお気に入りのクリップを簡単に見返し、共有することができます。これにより、ユーザーは面白いクリップを迅速かつ効率的に見つけ、共有することができます。

想定されるユーザー層

	•	性別: 主に男性
	•	年齢: 20代
	•	趣味: ゲーム
	•	利用行動: Twitchのクリップを頻繁に視聴し、面白いクリップを見返したいと考えている

サービスコンセプト

ユーザーの課題

現状、TwitchのクリップはTwitch上で探すには5つ以上のアクションが必要であり、特定の動画のクリップしか探せないため非常に面倒です。

解決方法

クリップ検索に特化したサービスを作成することで、ユーザーが簡単にクリップを検索できるようにします。例えば、配信者名、ゲーム名、日時での検索機能を提供することで、ユーザーは迅速に目的のクリップにアクセスできます。

サービス開発の背景

現状のクリップ検索サイトが使い勝手が悪いと感じたためです。以下の具体的な問題点を改善します。

	•	配信者名ではなく、配信者IDでしか検索できない
	•	ゲーム名で検索できない
	•	再生回数を入力しなければならない（ユーザーは再生回数が多いものを見たいはず）
	•	デザインが質素

これらの問題点を解決することで、より使いやすいクリップ検索サービスを提供します。

サービスのビジョン

目指す方向性

	•	配信者名で検索できるようにする
	•	ゲーム名で絞り込めるようにする
	•	Twitchと同じようなUI・デザインに近づける
	•	ユーザーが慣れ親しんだTwitchのデザインに近づけることで、違和感なく利用できるようにします。

差別化ポイント

競合サイト①: Twitch（https://www.twitch.tv/）

	•	懸念点: Twitch自体がクリップ検索機能を追加する可能性がある
	•	差別化: Twitchはクリエイター側に寄り添った機能が多く、ユーザー向けの機能追加は少ないと予想

競合サイト②: ClipNote（https://clipnote.net/）

	•	懸念点: 既にクリップ検索・お気に入り登録機能を実装している
	•	差別化: SEO対策で上位表示を狙い、日本配信者に特化することで差別化

競合サイト③: Twitch Clip Search（https://www.twitch-clip-search.com/）

	•	懸念点: 唯一の日本配信者限定のクリップ検索サイト
	•	差別化: 配信者ID以外での検索機能や、ゲーム名検索、お気に入り登録機能を追加

実装を予定している機能

MVP（Minimum Viable Product）

	•	ログイン認証: 閲覧・検索はログインなしで可能。いいねする際にログインが必要
	•	検索機能: 
	　ゲーム名検索
	　MVPでは完全一致での検索とする。
	　配信者名検索（候補検索）
	　MVPで可能なら配信者名での検索。ひとまずは、日本人の配信者IDでの検索を可能にする
　　日時検索
　　1日前、１週間前、１ヶ月前、３ヶ月間の４つでの検索。デフォルトは１週間
	•	いいね機能: 面白かったクリップをいいねすることができ、いいねしたクリップはユーザー画面で簡    単に見返せる
	•	共有機能: 面白いクリップを共有できる

その後の機能

	•	プレイリスト機能: クリップを連続再生することができる
	•	ランキング機能: 評価数の多いクリップをランキング形式で紹介
 	•	特定の配信者のクリップを簡単に検索できる機能:ログインユーザー限定。twtichでフォローしている配信者を左のタブに表示する。その配信者タブを押すと、その配信者のクリップが簡単に検索できる。

技術スタックと実装方針

フロントエンド

	•	Next.js: フロントエンドフレームワークとして使用。サーバーサイドレンダリング（SSR）や静的サイト生成（SSG）を活用。また、上位に出てくるようにしたいため、SEO対策としても使用
	

バックエンド

	•	Ruby on Rails APIモード: バックエンドとして使用。データベースとのやり取りや認証機能を提供

外部API

	•	Twitch API: クリップデータの取得や検索に使用

SEO対策

	•	キーワードリサーチ: 適切なキーワードを選定し、コンテンツに組み込む
	•	メタタグの最適化: タイトルタグ、メタディスクリプションを適切に設定
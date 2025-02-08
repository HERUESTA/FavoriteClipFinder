# サービス名<br>
https://favoriteclipfinder.com

# 目次
* サービス概要
* サービスURL
* サービス開発の背景
* 機能紹介
* 技術構成について
  * 使用技術
  * ER図
  * 画面遷移図

# サービス概要
FavoriteClipFinderは、日本のTwitch配信者を簡単に検索ができるサービスです。
Twitchと同じようなデザインと操作性でクリップを簡単に見つけ閲覧することができます。
見つけたクリップをプレイリストにして他者と楽しむことも可能です。

# サービスURL
https://favoriteclipfinder.com

# サービス開発の背景
私はゲーム配信を閲覧するのが好きでよくTwitch配信を閲覧しておりました。
その中でYoutubeshortsやtiktokのような短い時間でも楽しめるクリップというものも閲覧していました。
しかし、現状のTwitchでは今現在配信を行なっている配信者やゲームは楽しむことができるのですが
過去のアーカイブを閲覧しようとすると複数のステップを踏まなければならず面倒だと感じておりました。
そのため、その面倒な部分をTwitchと同じような操作感で楽しめるために今回アプリを作成しました。


# 機能紹介
## ユーザー登録/ログイン
[![Image from Gyazo](https://i.gyazo.com/5062496373c63c688c4b49db50205738.gif)](https://gyazo.com/5062496373c63c688c4b49db50205738)
名前・メールアドレス・パスワード・確認用パスワードを入力してユーザー登録を行うことができます。
Twitchアカウントを用いて、Twitchログインを行うことも可能です。

## 🎮配信者・ゲーム名検索機能
[![Image from Gyazo](https://i.gyazo.com/82cfbd3d86201390231e5151693b3709.gif)](https://gyazo.com/82cfbd3d86201390231e5151693b3709)
配信者リストやゲーム名から直感的にクリップ検索を行うことができます。
Twitchと同じ操作感のため、違和感なく使用することができます。

## 🎵プレイリスト作成機能
[![Image from Gyazo](https://i.gyazo.com/295eed5a4a525c4570a4da3d91e8e65c.gif)](https://gyazo.com/295eed5a4a525c4570a4da3d91e8e65c)
気に入ったクリップがあれば、保存ボタンを押下してプレイリストを作成することが可能です。
「公開」「非公開」が選べるので好きな公開範囲で作成することができます。「公開」のプレイリストはTOPページで他のユーザーからも閲覧が可能になります。

# 技術構成について
## 使用技術
| カテゴリ | 技術内容 |
|:---|:---:|
| インフラ | Fly.io |
| サーバーサイド | Ruby on Rails7.2 | 
| フロントエンド | Ruby on Rails ・ JavaScript |
| CSSフレームワーク | Tailwindcss + DaisyUI |
| WebAPI | TwitchAPI |
| データベースサーバー | PostgreSQL17 |
| バージョン管理ツール | GitHub |

## ER図
![image](https://github.com/user-attachments/assets/6d08e6bd-60d2-4919-97bf-b433c81cc42c)





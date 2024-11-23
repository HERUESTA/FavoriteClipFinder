require "sidekiq/web"


Rails.application.routes.draw do
    # Devise のルート
    devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  # root_path
  root "users#index"

  # 配信者ID検索用ルート
  get "streamers/show", to: "streamers#show"

  # ゲームID検索用ルート
  get "games/show", to: "games#show"

  # 検索ルート
  get "search", to: "search#index"

  # プレイリストクリップ用ルート
  resources :playlist_clips, only: [ :create ]

  # プレイリストのルート
  resources :playlists, only: [ :show ]

  # マイページ用ルート
  get "show", to: "users#show", as: "show"

  # CI/CD用route
  get "up" => "rails/health#show", as: :rails_health_check

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # 認証をハードコード
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end

  # Sidekiq
  mount Sidekiq::Web => "/mgmt/sidekiq"
end

Rails.application.routes.draw do
    # Devise のルート
    devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  # root_path
  root "users#index"

  # 静的なルートを優先
  get "streamers/show", to: "streamers#show", as: "streamer_show"

  # 動的なルートは下に定義
  get "streamers/:name", to: "streamers#show", as: "streamer"


  # CI/CD用route
  get "up" => "rails/health#show", as: :rails_health_check

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end

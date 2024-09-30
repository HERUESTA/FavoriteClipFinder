Rails.application.routes.draw do
  # ログイン・ログアウト用route
  devise_for :users

  # root_path
  root "users#index"



  # CI/CD用route
  get "up" => "rails/health#show", as: :rails_health_check

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end

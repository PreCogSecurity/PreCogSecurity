Rails.application.routes.draw do
  resources :lists, only: [:create, :destroy] do
    resources :tasks, except: [:new, :edit, :show]
  end

  # Liveness/readiness probe for load balancers and uptime monitors.
  get "/health", to: "health#show"

  root "tasks#index"
end
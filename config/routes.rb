Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'home#index'
  resources :items
  namespace :api, {format: 'json'} do
    namespace :v1 do
      resources :items, only: [:index, :show]
    end
  end
end

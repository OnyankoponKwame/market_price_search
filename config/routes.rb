Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root to: 'home#index'
  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'
  resources :users, only: %i[new create]
  resources :search_conditions
  namespace :api, { format: 'json' } do
    namespace :v1 do
      resources :items, only: %i[index show]
    end
  end
  get '*path', to: 'home#index' # どのURLにリクエストが来たとしてもhome#indexアクションを使用する
end

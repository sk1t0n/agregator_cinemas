Rails.application.routes.draw do
  root 'movies#index'
  devise_for :users
  resources :movies, only: [:index, :show]
  resources :genres, only: [:index, :show]
  resources :cinemas

  namespace :admin do
  	resources :movies, except: [:index, :show]
  	resources :genres, except: [:index, :show]
  end
end

Rails.application.routes.draw do
  resources :signups, only: [:create, :show]

  post :signin, to: 'sessions#create'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end

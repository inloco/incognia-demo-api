Rails.application.routes.draw do
  resources :signups, only: [:create, :show]

  post :signin, to: 'sessions#create'
  scope :signin do
    post :validate_otp, to: 'sessions#validate_otp'
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end

Rails.application.routes.draw do
  namespace :web do
    resources :sessions, only: [:new, :create]
  end
  resources :signups, only: [:create, :show]

  post :signin, to: 'sessions#create'
  scope :signin do
    post :validate_otp, to: 'sessions#validate_otp'
  end

  root to: redirect('web')
end

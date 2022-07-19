Rails.application.routes.draw do
  namespace :web do
    resources :sessions, only: [:new, :create]
    namespace :sessions do
      post :validate_otp
    end
    get :dashboard, to: 'dashboard#show'

    root 'dashboard#show'
  end
  resources :signups, only: [:create, :show]

  post :signin, to: 'sessions#create'
  scope :signin do
    post :validate_otp, to: 'sessions#validate_otp'
    post :validate_qrcode, to: 'sessions#validate_qrcode'
  end

  root to: redirect('web')
end

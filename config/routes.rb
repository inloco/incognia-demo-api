Rails.application.routes.draw do
  namespace :web do
    resource :session, only: [:new, :create, :destroy] do
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

  resource :assessments, only: [] do
    member do
      post :assess
    end
  end

  root to: redirect('web')
end

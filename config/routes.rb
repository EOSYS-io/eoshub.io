require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config.merge(controllers: { confirmations: "admin/admin_users/confirmations",
                                                                           sessions: "admin/admin_users/sessions" })
  ActiveAdmin.routes(self)

  root to: 'root#index'
  get 'health_check.html', to: proc{[200, {}, ['<html><head></head><body>HealthCheck OK</body></html>']]}

  resources :users do
    member do
      post :confirm_email
      post :create_eos_account
    end
  end

  resources :orders, only: [:create, :show] do
    collection do
      post :request_payment
    end

    member do
      post :create_eos_account
      get :show_error
    end
  end

  resources :payment_results, only: [:create]

  resources :products, only: [] do
    collection do
      get 'eos_account'
    end
  end

  resources :app_state, only: [:index]

  namespace :eos_ram_price_histories do
    get 'data'
  end

  namespace :vote_stats do
    get 'recent_stat'
  end

  resources :producers, only: [:index]

  devise_scope :admin_user do
    patch "/admin/confirmation" => "admin/admin_users/confirmations#confirm", as: :confirm_admin_user_confirmation
  end

  authenticate :admin_user do
    mount Sidekiq::Web => '/admin/sidekiq'
  end

  get '*path', to: 'root#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

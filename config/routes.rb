Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config.merge(controllers: { confirmations: "admin/admin_users/confirmations" })
  ActiveAdmin.routes(self)
  root to: 'root#index'
  get 'health_check.html', to: proc{[200, {}, ['<html><head></head><body>HealthCheck OK</body></html>']]}

  resources :users do
    member do
      get :confirm_email
      post :create_eos_account
    end
  end

  namespace :eos_ram_price_histories do
    get 'data'
  end

  devise_scope :admin_user do
    patch "/admin/confirmation" => "admin/admin_users/confirmations#confirm", as: :confirm_admin_user_confirmation
  end

  get '*path', to: 'root#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

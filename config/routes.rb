Rails.application.routes.draw do
  root to: 'root#index'
  get 'health_check.html', to: proc{[200, {}, ['<html><head></head><body>HealthCheck OK</body></html>']]}

  resources :users do
    member do
      get :confirm_email
      post :create_eos_account
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

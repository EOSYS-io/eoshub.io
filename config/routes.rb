Rails.application.routes.draw do
  root to: 'root#index'
  get 'health_check.html', to: proc{[200, {}, ['<html><head></head><body>HealthCheck OK</body></html>']]}

  resources :users do
    member do
      get :confirm_email
    end
  end

  get '*path', to: 'root#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

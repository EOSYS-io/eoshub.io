Rails.application.routes.draw do
  root to: 'root#index'
  get 'root/index'
  get 'health_check.html', to: proc{[200, {}, ['<html><head></head><body>HealthCheck OK</body></html>']]}
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

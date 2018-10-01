module Admin::AdminUsers
  class SessionsController < Devise::SessionsController
    include ::ActiveAdmin::Devise::Controller
  end
end
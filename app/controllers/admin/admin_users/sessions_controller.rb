module Admin::AdminUsers
  class SessionsController < Devise::SessionsController
    layout 'admin/admin_users/sessions'
  end
end
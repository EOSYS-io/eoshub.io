class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def access_denied(exception)
    flash[:warning] = exception.message
    return redirect_to new_admin_user_session_path if current_admin_user.nil?
    return redirect_to new_admin_user_confirmation_path unless current_admin_user.confirmed?
    redirect_back(fallback_location: admin_root_path)
  end
end

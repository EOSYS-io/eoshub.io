class ApplicationController < ActionController::Base
  include Rescuable

  protect_from_forgery with: :exception

  # Payletter return url
  skip_before_action :verify_authenticity_token, if: -> { controller_name == 'orders' && action_name == 'create' }

  before_action :set_locale

  rescue_from StandardError, with: :unexpected_error

  rescue_from ActiveRecord::RecordNotFound, with: :object_not_found

  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  rescue_from ArgumentError, with: :parameter_missing

  rescue_from Exceptions::DefaultError, with: :render_default_error

  rescue_from Exceptions::DefaultError, with: :render_default_error

  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity

  def access_denied(exception)
    flash[:warning] = exception.message
    return redirect_to new_admin_user_session_path if current_admin_user.nil?
    return redirect_to new_admin_user_confirmation_path unless current_admin_user.confirmed?
    redirect_back(fallback_location: admin_root_path)
  end
end

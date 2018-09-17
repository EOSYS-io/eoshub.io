class ApiController < ActionController::API
  include Rescuable

  before_action :set_locale

  rescue_from StandardError, with: :unexpected_error

  rescue_from ActiveRecord::RecordNotFound, with: :object_not_found

  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  rescue_from ArgumentError, with: :parameter_missing

  rescue_from Exceptions::DefaultError, with: :render_default_error

  rescue_from Exceptions::DefaultError, with: :render_default_error

  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
end
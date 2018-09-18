module Rescuable
  extend ActiveSupport::Concern
  include Loggable

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def object_not_found(exception)
    render_default_error(Exceptions::DefaultError.new(cause: exception, message: I18n.t('errors.object_not_found'), status_code: :not_found))
  end

  def parameter_missing(exception)
    render_default_error(Exceptions::DefaultError.new(cause: exception, message: (exception.nil? ? I18n.t('errors.parameter_missing') : exception), status_code: :bad_request))
  end

  def unexpected_error(exception)
    logger.error { exception.message.to_s }
    render_default_error(Exceptions::DefaultError.new(cause: exception, message: I18n.t('errors.unexpected_error'), status_code: :internal_server_error))
  end

  def render_default_error(exception)
    logger.i exception, exception.objects
    json = {
        message: exception.message,
        code: exception.error_code,
        objects: exception.objects
    }
    render json: json, status: exception.status_code
  end

  def render_unprocessable_entity(exception)
    render_default_error(Exceptions::DefaultError.new(cause: exception, message: exception.message, status_code: :unprocessable_entity))
  end

  def render_unauthorized(realm = 'Application')
    self.headers['WWW-Authenticate'] = %(Token realm="#{realm.delete('"')}")
    raise_unauthorized
  end

  def raise_unauthorized
    render_default_error(Exceptions::DefaultError.new(message: I18n.t('errors.unauthorized'), status_code: :unauthorized))
  end
end

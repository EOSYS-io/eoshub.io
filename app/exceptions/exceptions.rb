# frozen_string_literal: true
module Exceptions
  # Error Codes
  ## General
  MISSING_PARAMETER = { msg: I18n.t('errors.parameter_missing'), error_code: 1, status_code: 400 }.freeze

  class DefaultError < RuntimeError
    attr_accessor :status_code, :error_code, :objects

    def initialize(hash = {}, objects = [])
      @status_code = hash.key?(:status_code) ? hash[:status_code] : :unexpected_error
      @error_code = hash.key?(:error_code) ? hash[:error_code] : 0
      @objects = objects
      @context = {
          extra: {
              objects: objects
          }
      }

      msg = hash.key?(:msg) ? hash[:msg] : I18n.t('errors.unexpected_error')
      msg += " cause: #{hash[:cause].message}" if (!Rails.env.production? && !Rails.env.alpha?) && hash[:cause].present?
      super(msg)

      self.set_backtrace(hash[:cause].backtrace) if hash[:cause].present?
    end

    def as_json(options = nil)
      { error: message, code: error_code, objects: objects, cause: cause&.as_json }
    end
  end
end
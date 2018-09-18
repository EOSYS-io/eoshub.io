# frozen_string_literal: true
module Exceptions
  # Error Codes
  ## General
  MISSING_PARAMETER = { message: I18n.t('errors.parameter_missing'), error_code: 1, status_code: 400 }.freeze
  DUPLICATE_EOS_ACCOUNT = { message: I18n.t('users.eos_account_already_exist'), error_code: 2, status_code: :conflict }.freeze

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

      message = hash.key?(:message) ? hash[:message] : I18n.t('errors.unexpected_error')
      message += " cause: #{hash[:cause].message}" if (!Rails.env.production? && !Rails.env.alpha?) && hash[:cause].present?
      super(message)

      self.set_backtrace(hash[:cause].backtrace) if hash[:cause].present?
    end

    def as_json(options = nil)
      { message: message, code: error_code, objects: objects, cause: cause&.as_json }
    end
  end
end
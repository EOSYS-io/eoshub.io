# frozen_string_literal: true
module Exceptions
  # Error Codes
  ## General
  MISSING_PARAMETER = { message: I18n.t('errors.parameter_missing'), error_code: 1, status_code: :bad_request }.freeze
  DUPLICATE_EOS_ACCOUNT = { message: I18n.t('users.eos_account_already_exist'), error_code: 2, status_code: :conflict }.freeze
  DEACTIVATED_PRODUCT = { message: I18n.t('orders.deactivated_product'), error_code: 3, status_code: :bad_request }.freeze
  ORDER_NOT_EXIST = { message: I18n.t('orders.order_not_exist'), error_code: 4, status_code: :bad_request }.freeze
  ORDER_NOT_PAID = { message: I18n.t('orders.order_not_paid'), error_code: 5, status_code: :bad_request }.freeze
  ORDER_ALREADY_DELIVERED = { message: I18n.t('orders.order_already_delivered'), error_code: 6, status_code: :bad_request }.freeze

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
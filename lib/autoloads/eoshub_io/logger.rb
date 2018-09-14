# frozen_string_literal: true
module EoshubIo
  class Logger < ActiveSupport::Logger
    def f(exception, extra_values = {})
      if Rails.env.production? || Rails.env.alpha?
        send_exception(exception, extra: extra_values)
      end

      Rails.logger.fatal { exception.message.to_s }
      Rails.logger.fatal { extra_values.to_s } unless extra_values.blank?
      exception.backtrace&.each { |line| Rails.logger.fatal { line } }
    end

    def e(exception, extra_values = {})
      if Rails.env.production? || Rails.env.alpha?
        send_exception(exception, extra: extra_values)
      end

      Rails.logger.error { exception.message.to_s }
      Rails.logger.error { extra_values.to_s } unless extra_values.blank?
      exception.backtrace&.each { |line| Rails.logger.error { line } }
    end

    def w(exception, extra_values = {})
      if Rails.env.production? || Rails.env.alpha?
        send_message(exception, extra: extra_values, level: :warning)
      end

      Rails.logger.warn exception.message.to_s
      Rails.logger.warn extra_values.to_s unless extra_values.blank?
      exception.backtrace&.each { |line| Rails.logger.warn { line } }
    end

    def i(exception, extra_values = {})
      Rails.logger.info { exception.message.to_s }
      Rails.logger.info { extra_values.to_s } unless extra_values.blank?
      exception.backtrace&.each { |line| Rails.logger.info { line } } if exception.backtrace.present?
    end

    def d(exception, extra_values = {})
      Rails.logger.debug { exception.message.to_s }
      Rails.logger.debug { extra_values.to_s } unless extra_values.blank?
      exception.backtrace&.each { |line| Rails.logger.debug { line } } if exception.backtrace.present?
    end

    def f_msg(tag, message)
      Rails.logger.tagged(tag) { Rails.logger.fatal { message } }
    end

    def e_msg(tag, message)
      Rails.logger.tagged(tag) { Rails.logger.error { message } }
    end

    def w_msg(tag, message)
      Rails.logger.tagged(tag) { Rails.logger.warn { message } }
    end

    def i_msg(tag, message)
      Rails.logger.tagged(tag) { Rails.logger.info { message } }
    end

    def d_msg(tag, message)
      Rails.logger.tagged(tag) { Rails.logger.debug { message } }
    end

    protected

    def send_message(message, options = {})
      # send message to error monitor tools like sentry
    end

    def send_exception(exception, options = {})
      # send exception to error monitor tools like sentry
    end
  end
end

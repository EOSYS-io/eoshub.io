module Loggable
  extend ActiveSupport::Concern

  module ClassMethods
    def log_tag
      name
    end

    def logger
      Rails.logger
    end
  end

  def log_tag
    if self.instance_of?(Class)
      self.name
    else
      self.class.name
    end
  end

  def logger
    Rails.logger
  end
end
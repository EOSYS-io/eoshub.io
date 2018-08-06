module Admin::AdminUsers
  class ConfirmationsController < Devise::ConfirmationsController
    include ::ActiveAdmin::Devise::Controller

    def show
      if params[:confirmation_token].present?
        @confirmation_token = params[:confirmation_token]
      elsif params[resource_name].try(:[], :confirmation_token).present?
        @confirmation_token = params[resource_name][:confirmation_token]
      end

      self.resource = resource_class.find_by(confirmation_token: @confirmation_token)

      raise 'resource is nil!' if resource.nil?

      super if resource.confirmed?
    end

    def confirm
      @confirmation_token = params[resource_name].try(:[], :confirmation_token)
      self.resource = resource_class.find_by(confirmation_token: @confirmation_token)
      resource.assign_attributes(permitted_params) unless params[resource_name].nil?

      if resource.valid? && resource.password_match?
        self.resource.confirm
        set_flash_message :notice, :confirmed
        sign_in_and_redirect resource_name, resource
      else
        render :show
      end
    end

    private
    
    def permitted_params
      params.require(resource_name).permit(:confirmation_token, :password, :password_confirmation)
    end
  end
end
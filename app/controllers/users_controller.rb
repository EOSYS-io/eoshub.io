class UsersController < ApiController
  include EosAccount

  before_action :event_activated?
  
  def create
    unless User.qualify_for_event(request.remote_ip)
      render json: { message: I18n.t('users.too_many_request_with_same_ip_address') }, status: :precondition_failed and return
    end

    @user = User.find_by(email: params[:email])
    if @user.present?
      if @user.eos_account_created?
        render json: { message: I18n.t('users.already_eos_account_created_email') }, status: :bad_request and return
      else
        @user.regenerate_confirm_token!
      end
    else
      @user = User.new(email: params[:email])
      unless @user.save
        render json: { message: I18n.t('users.failed_to_create_email_verification_log') }, status: :internal_server_error and return
      end
    end

    begin
      UserMailer.email_confirmation(@user).deliver
      render json: { message: I18n.t('users.create_ok') }, status: :ok
    rescue Net::SMTPAuthenticationError
      render json: { message: I18n.t('users.smtp_authentication_error') }, status: :internal_server_error
    end
  end

  def confirm_email
    confirm_token = params[:id]

    user = User.has_valid_confirm_token(confirm_token)
    if user.present?
      user.email_confirmed!
      render json: { message: I18n.t('users.email_confirmed') }, status: :ok
    else
      render json: { message: I18n.t('users.invalid_email_confirm_token') }, status: :bad_request
    end
  end

  def create_eos_account
    user = User.find_by(confirm_token: params[:id])

    if user.blank?
      render json: { message: I18n.t('users.eos_account_creation_failure_no_such_email') }, status: :precondition_failed
    elsif user.email_saved?
      render json: { message: I18n.t('users.eos_account_creation_failure_email_not_confirmed') }, status: :precondition_failed
    elsif user.eos_account_created?
      render json: { message: I18n.t('users.eos_account_creation_failure_already_created') }, status: :precondition_failed
    else
      raise Exceptions::DefaultError, Exceptions::DUPLICATE_EOS_ACCOUNT if eos_account_exist?(params[:account_name])

      creator_eos_account = @eos_account_product.creator_event
      eos_account = params[:account_name]
      response = request_eos_account_creation(creator_eos_account, eos_account, params[:pubkey])
      if response.code == 200
        user.assign_attributes(eos_account: eos_account, ip_address: request.remote_ip)
        user.eos_account_created!
        render json: { message: I18n.t('users.eos_account_created', eos_account: eos_account) }, status: :ok
      elsif response.return_code == :couldnt_connect
        render json: { message: I18n.t('users.eos_wallet_connection_failed')}, status: :internal_server_error
      elsif JSON.parse(response.body).dig('code') == 'ECONNREFUSED'
        render json: { message: I18n.t('users.eos_node_connection_failed') }, status: response.code
      else
        render json: response.body, status: response.code
      end
    end
  end

  private

  def event_activated?
    @eos_account_product = Product.eos_account
    raise Exceptions::DefaultError, Exceptions::NOT_EVENT_PERIOD unless @eos_account_product&.event_activation
  end
end

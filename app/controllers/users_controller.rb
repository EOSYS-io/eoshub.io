class UsersController < ApiController
  include EosAccount

  def create
    @user = User.find_by(email: params[:email])
    if @user.present?
      if @user.eos_account_created?
        render json: { message: I18n.t('users.already_eos_account_created_email') }, status: :bad_request and return
      end
    else
      @user = User.new(email: params[:email])
      unless @user.save
        render json: { message: I18n.t('user.failed_to_create_email_verification_log') }, status: :internal_server_error and return
      end
    end

    UserMailer.email_confirmation(@user).deliver
    render json: { message: I18n.t('users.create_ok') }, status: :ok
  rescue Net::SMTPAuthenticationError
    render json: { message: I18n.t('users.smtp_authentication_error') }, status: :internal_server_error
  end

  def confirm_email
    confirm_token = params[:id]
    user = User.find_by(confirm_token: confirm_token)
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

      response = request_eos_account_creation(params[:account_name], params[:pubkey])
      if response.code == 200
        user.eos_account_created!
        render json: { message: I18n.t('users.eos_account_created') }, status: :ok
      elsif response.return_code == :couldnt_connect
        render json: { message: I18n.t('users.eos_wallet_connection_failed')}, status: :internal_server_error
      elsif JSON.parse(response.body).dig('code') == 'ECONNREFUSED'
        render json: { message: I18n.t('users.eos_node_connection_failed') }, status: response.code
      else
        render json: response.body, status: response.code
      end
    end
  end
end

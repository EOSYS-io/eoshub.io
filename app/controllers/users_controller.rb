class UsersController < ApiController
  def create
    @user = User.find_by(email: params[:email])
    if @user.present?
      unless @user.email_saved?
        render json: { msg: I18n.t('users.already_confirmed_email') }, status: :bad_request and return
      end
    else
      @user = User.new(email: params[:email])
      unless @user.save
        render json: { msg: I18n.t('user.failed_to_create_email_verification_log') }, status: :internal_server_error and return
      end
    end

    UserMailer.email_confirmation(@user).deliver
    render json: { msg: I18n.t('users.create_ok') }, status: :ok
  end

  def confirm_email
    confirm_token = params[:id]
    user = User.find_by(confirm_token: confirm_token)
    if user.present?
      user.email_confirmed!
      redirect_to "#{Rails.configuration.urls['host_url']}#{Rails.configuration.urls['account_create_email_confirmed_url']}/#{confirm_token}?email=#{user.email}"
    else
      redirect_to "#{Rails.configuration.urls['host_url']}#{Rails.configuration.urls['account_create_email_confirm_failure_url']}"
    end
  end

  def create_eos_account
    user = User.find_by(confirm_token: params[:id])

    if user.blank?
      render json: { msg: I18n.t('users.eos_account_creation_failure_no_such_email') }, status: :precondition_failed
    elsif user.email_saved?
      render json: { msg: I18n.t('users.eos_account_creation_failure_email_not_confirmed') }, status: :precondition_failed
    elsif user.eos_account_created?
      render json: { msg: I18n.t('users.eos_account_creation_failure_already_created') }, status: :precondition_failed
    else
      if helpers.eos_account_exist?(params[:account_name])
        render json: { msg: I18n.t('user.eos_account_already_exist') }, status: :conflict and return
      end

      response = helpers.create_eos_account(params[:account_name], params[:pubkey])
      if response.code == 200
        user.eos_account_created!
        render json: { msg: I18n.t('user.eos_account_created') }, status: :ok
      else
        render json: response.body, status: response.code
      end
    end
  end
end

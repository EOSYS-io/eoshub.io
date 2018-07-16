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
    user = User.find_by(confirm_token: params[:id])
    if user.present?
      user.email_confirmed!
      render json: { msg: "Your email has been confirmed." }, status: :ok
    else
      render json: { msg: 'Sorry. User does not exist' }, status: :precondition_failed
    end
  end

  def create_eos_account
    user = User.find_by(confirm_token: params[:id])

    if user.blank?
      render json: { msg: 'User does not exist with this email' }, status: :precondition_failed
    elsif user.email_saved?
      render json: { msg: 'Email is not confirmed' }, status: :precondition_failed
    elsif user.eos_account_created?
      render json: { msg: 'EOS account already created with this email' }, status: :precondition_failed
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

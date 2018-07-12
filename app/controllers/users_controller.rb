class UsersController < ApiController
  def create
    @user = User.find_by(email: params[:email])
    if @user.present?
      render status: :bad_request, json: { msg: I18n.t('users.already_confirmed_email') } unless @user.email_saved?
    else
      @user = User.new(email: params[:email])
      unless @user.save
        render status: :internal_server_error, json: { msg: I18n.t('user.failed_to_create_email_verification_log') }
      end
    end

    UserMailer.email_confirmation(@user).deliver
    render status: :ok, json: { msg: I18n.t('users.create_ok') }
  end

  def confirm_email
    user = User.find_by(confirm_token: params[:id])
    if user.present?
      user.email_confirmed!
      render status: :ok, json: { msg: "Your email has been confirmed." }
    else
      render status: :precondition_failed, json: { msg: 'Sorry. User does not exist' }
    end
  end

  def create_eos_account
    user = User.find_by(confirm_token: params[:id])

    if user.blank?
      render status: :precondition_failed, json: { msg: 'User does not exist with this email' }
    elsif user.email_saved?
      render status: :precondition_failed, json: { msg: 'Email is not confirmed' }
    elsif user.eos_account_created?
      render status: :precondition_failed, json: { msg: 'EOS account already created with this email' }
    else
      return render status: :conflict, json: { msg: I18n.t('user.eos_account_already_exist') } if helpers.eos_account_exist?(params[:account_name])

      response = helpers.create_eos_account(params[:account_name], params[:pubkey])
      if response.code == 200
        user.eos_account_created!
        render status: :ok, json: { msg: I18n.t('user.eos_account_created') }
      else
        render status: response.code, json: response.body
      end
    end
  end
end

class UsersController < ApplicationController
  def create
    @user = User.find_by(email: user_params[:email])
    if @user.present?
      if @user.email_confirmed
        render status: :bad_request, json: { msg: I18n.t('users.already_confirmed_email') }
      end
    else
      @user = User.new(email: user_params[:email])
      unless @user.save
        render status: :internal_server_error, json: { msg: I18n.t('user.failed_to_create_email_verification_log') }
      end
    end

    UserMailer.email_confirmation(@user).deliver
    render status: :ok, json: { msg: I18n.t('users.create_ok') }
  end

  def confirm_email
    user = User.find_by_confirm_token(params[:id])
    if user.present?
      user.email_activate
      render status: :ok, json: { msg: "Welcome to the EOS! Your email has been confirmed." }
    else
      render status: :precondition_failed, json: { msg: 'Sorry. User does not exist' }
    end
  end
end

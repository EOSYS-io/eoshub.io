class UsersController < ApplicationController
  def create
    @user = User.new(user_params)    
    if @user.save
      UserMailer.email_confirmation(@user).deliver
      render status: :ok, json: { msg: 'Please confirm your email address to continue' }
    else
      render status: :internal_server_error, json: { msg: 'Ooooppss, something went wrong!' }
    end
  end

  def confirm_email
    user = User.find_by_confirm_token(params[:id])
    if user
      user.email_activate
      render status: :ok, json: { msg: "Welcome to the EOS! Your email has been confirmed." }
    else
      render status: :precondition_failed, json: { msg: 'Sorry. User does not exist' }
    end
  end
end

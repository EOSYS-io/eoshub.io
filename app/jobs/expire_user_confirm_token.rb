class ExpireUserConfirmTokenJob < ApplicationJob
  def perform(user_id)
    User.find_by(id: user_id).clear_confirm_token!
  end
end
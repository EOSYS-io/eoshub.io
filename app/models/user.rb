# == Schema Information
#
# Table name: users
#
#  id              :bigint(8)        not null, primary key
#  confirm_token   :string(22)
#  email           :string(255)      not null
#  email_confirmed :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email)
#

class User < ApplicationRecord
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true
  before_create :confirmation_token

  def name
    email.split('@').dig(0)
  end

  def email_activate
    update!(email_confirmed: true, confirm_token: nil)
  end

  private

  def confirmation_token
    if self.confirm_token.blank?
      self.confirm_token = SecureRandom.urlsafe_base64.to_s
    end
  end
end

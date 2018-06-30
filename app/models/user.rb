class User < ApplicationRecord
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true

  def name
    email.split('@').dig(0)
  end
end

class UserMailer < ApplicationMailer
  def email_confirmation(user)
    @user = user
    mail(to: "#{user.name} <#{user.email}>", subject: I18n.t('user_mailer.subject'))
  end
end

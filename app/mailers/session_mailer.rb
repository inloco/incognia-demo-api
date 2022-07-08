class SessionMailer < ApplicationMailer
  def otp_email(recipient:, otp_code:)
    @otp_code = otp_code

    mail to: recipient, subject: 'Temporary Incognia sign in code'
  end
end

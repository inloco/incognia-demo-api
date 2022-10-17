module Signin
  class PasswordlessForm
    include ActiveModel::Model

    attr_accessor :user, :installation_id

    validates :user, presence: true
    validates :installation_id, presence: true

    def submit
      return if invalid?

      assessment = Signin::Register.call(user:, installation_id:)

      return user if assessment.risk_assessment.to_sym == :low_risk

      code = GenerateSigninCode.call(user: user)
      SessionMailer.otp_email(recipient: user.email, otp_code: code)
        .deliver_later

      nil
    end
  end
end

module Signin
  class PasswordlessForm
    include ActiveModel::Model

    attr_accessor :user, :installation_id

    validates :user, presence: true
    validates :installation_id, presence: true

    def submit
      assessment = IncogniaApi.instance.register_login(
        account_id: user.account_id,
        installation_id: installation_id,
      )

      return user if assessment.risk_assessment.to_sym == :low_risk

      code = GenerateSigninCode.call(user: user)
      SessionMailer.otp_email(recipient: user.email, otp_code: code)
        .deliver_later

      nil
    end
  end
end

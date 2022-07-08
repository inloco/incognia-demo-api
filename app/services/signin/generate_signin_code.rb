module Signin
  class GenerateSigninCode
    OTP_LENGTH = 20.freeze
    EXPIRATION_TIME_IN_MINUTES = 5.freeze

    class << self
      def call(user:)
        code = SecureRandom.base64(OTP_LENGTH)

        SigninCode.create(
          code: code, user: user,
          expires_at: Time.now + EXPIRATION_TIME_IN_MINUTES.minutes
        )

        code
      end
    end
  end
end

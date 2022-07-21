module Signin
  class GenerateSigninCode
    OTP_LENGTH = 20.freeze
    EXPIRATION_TIME_IN_MINUTES = 5.freeze

    class << self
      def call(user:, expiration_time: nil)
        code = SecureRandom.base64(OTP_LENGTH)
        expires_at = Time.now +
          (expiration_time || EXPIRATION_TIME_IN_MINUTES.minutes)

        SigninCode.create(code:, user:, expires_at:)

        code
      end
    end
  end
end

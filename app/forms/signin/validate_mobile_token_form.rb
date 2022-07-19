module Signin
  class ValidateMobileTokenForm
    include ActiveModel::Model
    include Signin::CodeValidations

    EXPIRATION_TIME_IN_SECONDS = 10.freeze

    attr_accessor :user, :code

    validates :user, presence: true

    def submit
      return if invalid?

      ActiveRecord::Base.transaction do
        signin_code.update(used_at: Time.now)

        Signin::GenerateSigninCode.(
          user:, expiration_time: EXPIRATION_TIME_IN_SECONDS.seconds
        )
      end
    end

    def signin_code
      @signin_code ||= SigninCode.find_by(user:, code:)
    end
  end
end

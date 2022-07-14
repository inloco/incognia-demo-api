module Signin
  class OtpForm
    include ActiveModel::Model

    attr_accessor :user, :code

    validates :user, presence: true
    validates :code, presence: true
    validate :code_existence
    validate :code_usage, if: :signin_code
    validate :code_expiration, if: :signin_code

    def submit
      return if invalid?

      signin_code.update(used_at: Time.now)

      user
    end

    private

    def signin_code
      @signin_code ||= SigninCode.find_by(user:, code:)
    end

    def code_existence
      errors.add(:code, :invalid) unless signin_code
    end

    def code_usage
      errors.add(:code, :already_used) if signin_code.used_at
    end

    def code_expiration
      errors.add(:code, :expired) if signin_code.expires_at < Time.now
    end
  end
end

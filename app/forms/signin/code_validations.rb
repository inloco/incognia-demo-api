module Signin
  module CodeValidations
    extend ActiveSupport::Concern

    included do
      validates :code, presence: true
      validate :code_existence
      validate :code_usage, if: :signin_code
      validate :code_expiration, if: :signin_code
    end

    private

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

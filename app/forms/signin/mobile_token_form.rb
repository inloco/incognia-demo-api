module Signin
  class MobileTokenForm
    include ActiveModel::Model

    attr_accessor :email

    validates :email, presence: true
    validate :user_existence, if: -> { email.present? }

    def submit
      return if invalid?

      GenerateSigninCode.call(user:)
    end

    private

    def user_existence
      errors.add(:email, :invalid) unless user
    end

    def user
      @user ||= User.find_by(email:)
    end
  end
end

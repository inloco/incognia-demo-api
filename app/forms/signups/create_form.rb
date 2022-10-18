module Signups
  class CreateForm
    include ActiveModel::Model

    EN_US_LOCALE = 'en-US'.freeze

    attr_accessor :account_id, :email, :installation_id
    attr_reader :structured_address

    validates :account_id, presence: true
    validates :installation_id, presence: true
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validate :email_uniqueness

    def submit
      return if invalid?

      signup_attrs = { installation_id:, structured_address: }.compact
      assessment = Signups::Register.call(**signup_attrs)

      User.create!(
        account_id:,
        email:,
        address: (structured_address ? { structured_address: } : nil),
        incognia_signup_id: assessment.id
      )
    rescue ActiveRecord::RecordNotUnique
      errors.add(:email, :taken)

      nil
    end

    def structured_address=(address)
      if address.present?
        @structured_address = address.merge(locale: EN_US_LOCALE)
      end

      @structured_address
    end

    private

    def email_uniqueness
      errors.add(:email, :taken) if User.exists?(email: email)
    end
  end
end

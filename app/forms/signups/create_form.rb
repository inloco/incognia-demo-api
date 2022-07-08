module Signups
  class CreateForm
    include ActiveModel::Model

    EN_US_LOCALE = 'en-US'.freeze

    attr_accessor :account_id, :email, :installation_id, :structured_address

    validates :account_id, presence: true
    validates :installation_id, presence: true
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    def submit
      return unless valid?

      assessment = IncogniaApi.instance.register_signup(**incognia_signup_attrs)

      User.create!(
        account_id: account_id,
        email: email,
        address: incognia_signup_attrs[:address]&.to_hash,
        incognia_signup_id: assessment.id
      )
    end

    private

    def incognia_signup_attrs
      return @incognia_signup_attrs if @incognia_signup_attrs

      @incognia_signup_attrs = {
        installation_id: installation_id,
      }

      if structured_address.present?
        structured_address.merge!(locale: EN_US_LOCALE) # For simplicity sake

        @incognia_signup_attrs.merge!(
          address: Incognia::Address::Structured.new(**structured_address)
        )
      end

      @incognia_signup_attrs
    end
  end
end

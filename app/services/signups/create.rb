module Signups
  class Create
    EN_US_LOCALE = 'en-US'.freeze

    class << self
      def call(attrs)
        new(**attrs).create
      end
    end

    def initialize(installation_id:, address: nil)
      @installation_id = installation_id
      @address = address

      if @address.present?
        @address.merge!(locale: EN_US_LOCALE) # For simplicity sake
      end
    end

    def create
      signup_attrs = { installation_id: installation_id }

      if address.present?
        signup_attrs.merge!(
          address: Incognia::Address::Structured.new(**address)
        )
      end

      assessment = IncogniaApi.instance.register_signup(**signup_attrs)

      Signup.create!(
        address: signup_attrs[:address]&.to_hash,
        incognia_signup_id: assessment.id
      )
    end

    private

    attr_reader :installation_id, :address
  end
end

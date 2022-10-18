module Signups
  class Register
    class << self
      def call(installation_id:, structured_address: nil)
        attrs = { installation_id: }

        if structured_address
          attrs.merge!(
            address: Incognia::Address::Structured.new(**structured_address)
          )
        end

        assessment = IncogniaApi::Adapter.new.register_signup(**attrs)

        AssessmentLog.create(
          api_name: Constants::API_NAME,
          incognia_id: assessment.request_id,
          incognia_signup_id: assessment.id,
        )

        assessment
      end
    end
  end
end

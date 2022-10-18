module Signin
  class Register
    class << self
      def call(user:, installation_id:)
        assessment = IncogniaApi::Adapter.new.register_login(
          account_id: user.account_id,
          installation_id:,
        )

        AssessmentLog.create(
          api_name: Constants::API_NAME,
          incognia_id: assessment.id,
          account_id: user.account_id,
          installation_id:
        )

        assessment
      end
    end
  end
end

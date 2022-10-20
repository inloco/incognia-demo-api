module Signups
  class GetReassessment
    class << self
      def call(user:)
        assessment = IncogniaApi::Adapter.new
          .get_signup_assessment(signup_id: user.incognia_signup_id)

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

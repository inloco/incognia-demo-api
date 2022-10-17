module Assessments
  class AssessSignup
    API_NAME = 'Onboarding'.freeze

    class << self
      def call(user:)
        Signups::GetReassessment.call(user:)

        Assessment.new(api_name: API_NAME, timestamp: Time.now)
      end
    end
  end
end

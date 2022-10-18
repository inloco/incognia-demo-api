module Assessments
  class AssessSignup
    class << self
      def call(user:)
        Signups::GetReassessment.call(user:)
      end
    end
  end
end

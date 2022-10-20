module Signups
  class GetReassessment
    class << self
      def call(user:)
        IncogniaApi::Adapter.new
          .get_signup_assessment(signup_id: user.incognia_signup_id)
      end
    end
  end
end

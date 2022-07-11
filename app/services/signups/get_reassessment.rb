module Signups
  class GetReassessment
    class << self
      def call(incognia_signup_id:)
        signup = Signup.find_by!(incognia_signup_id: incognia_signup_id)

        IncogniaApi.instance
          .get_signup_assessment(signup_id: incognia_signup_id)

        signup
      end
    end
  end
end

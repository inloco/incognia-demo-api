module Signups
  class GetReassessment
    class << self
      def call(incognia_signup_id:)
        user = User.find_by!(incognia_signup_id:)

        IncogniaApi::Adapter.new
          .get_signup_assessment(signup_id: incognia_signup_id)

        user
      end
    end
  end
end

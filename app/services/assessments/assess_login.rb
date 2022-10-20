module Assessments
  class AssessLogin
    API_NAME = 'Login'.freeze

    class << self
      def call(user:, installation_id:)
        Signin::Register.call(user:, installation_id:)

        Assessment.new(api_name: API_NAME, timestamp: Time.now)
      end
    end
  end
end

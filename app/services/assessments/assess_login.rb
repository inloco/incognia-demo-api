module Assessments
  class AssessLogin
    class << self
      def call(user:, installation_id:)
        Signin::Register.call(user:, installation_id:)
      end
    end
  end
end

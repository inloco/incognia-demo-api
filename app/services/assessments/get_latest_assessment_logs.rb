module Assessments
  class GetLatestAssessmentLogs
    class << self
      def call(user:, installation_id:)
        AssessmentLog.select('DISTINCT ON (api_name) api_name, *')
          .where(account_id: user.account_id, installation_id:)
          .or(AssessmentLog.where(incognia_signup_id: user.incognia_signup_id))
          .order(api_name: :asc, created_at: :desc)
      end
    end
  end
end

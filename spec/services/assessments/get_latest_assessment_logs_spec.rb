require 'rails_helper'

RSpec.describe Assessments::GetLatestAssessmentLogs, type: :service do
  subject(:get_latest_assessment_logs) do
    described_class.(user:, installation_id:)
  end
  let(:user) { build(:user) }
  let(:installation_id) { SecureRandom.uuid }

  let!(:onboarding_assessments) do
    3.times.map do |i|
      create(
        :assessment_log,
        :onboarding,
        incognia_signup_id: user.incognia_signup_id,
        created_at: i.day.from_now
      )
    end
  end

  let!(:non_onboarding_assessments) do
    3.times.map do |i|
      create(
        :assessment_log,
        :non_onboarding,
        account_id: user.account_id,
        installation_id:,
        created_at: i.day.from_now
      )
    end
  end
  let!(:random_assessments) { create_list(:assessment_log, 5) }
  let!(:latest_assessments) do
    [
      onboarding_assessments.last,
      non_onboarding_assessments.group_by(&:api_name).values.map(&:last)
    ].flatten
  end

  describe '.call' do
    it 'returns users last assessments for each use case' do
      expect(get_latest_assessment_logs).to match_array(latest_assessments)
    end
  end
end

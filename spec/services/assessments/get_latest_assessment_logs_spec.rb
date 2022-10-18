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
  AssessmentLog.api_names.except(:onboarding).values.each do |api_name|
    let!("#{api_name}_assessments") do
      3.times.map do |i|
        create(
          :assessment_log,
          api_name,
          account_id: user.account_id,
          installation_id:,
          created_at: i.day.from_now
        )
      end
    end
  end
  let!(:random_assessments) { create_list(:assessment_log, 5) }
  let!(:latest_assessments) {
    assessments = AssessmentLog.api_names.except(:onboarding).values.map do |api_name|
      send("#{api_name}_assessments").last
    end.flatten

    assessments << onboarding_assessments.last
  }

  describe '.call' do
    it 'returns users last assessments for each use case' do
      expect(get_latest_assessment_logs).to match_array(latest_assessments)
    end
  end
end

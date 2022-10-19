require 'rails_helper'

RSpec.describe Assessments::AssessForm, type: :model do
  subject(:form) { described_class.new(attrs) }
  let(:attrs) { {} }

  context 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:installation_id) }
  end

  describe '#submit' do
    subject(:submit) { form.submit }

    context 'when attributes are valid' do
      let(:attrs) { { user:, installation_id: } }
      let(:user) { build(:user) }
      let(:installation_id) { SecureRandom.uuid }
      let(:latest_assessment_logs) { build_list(:assessment_log, 2) }

      before do
        allow(Assessments::AssessSignup).to receive(:call)
        allow(Assessments::AssessLogin).to receive(:call)
        allow(Assessments::GetLatestAssessmentLogs).to receive(:call)
          .and_return(latest_assessment_logs)
      end

      it 'invokes assess signup service' do
        expect(Assessments::AssessSignup).to receive(:call).with(user:)

        submit
      end

      it 'invokes assess login service' do
        expect(Assessments::AssessLogin).to receive(:call)
          .with(user:, installation_id:)

        submit
      end

      it 'returns latest assessments' do
        expect(Assessments::GetLatestAssessmentLogs).to receive(:call)
          .with(user:, installation_id:)

        assessments = submit

        expect(assessments).to match_array(latest_assessment_logs)
      end
    end

    context 'when attributes are invalid' do
      let(:attrs) { {} }

      it 'does not request assessments' do
        expect(Assessments::AssessSignup).to_not receive(:call)
        expect(Assessments::AssessLogin).to_not receive(:call)

        submit
      end

      it 'returns falsy' do
        expect(submit).to be_falsy
      end
    end
  end
end

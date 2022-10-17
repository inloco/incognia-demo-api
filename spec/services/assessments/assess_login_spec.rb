require 'rails_helper'

RSpec.describe Assessments::AssessLogin, type: :service do
  subject(:assess) { described_class.(user:, installation_id:) }
  let(:user) { build(:user) }
  let(:installation_id) { SecureRandom.uuid }

  describe '.call' do
    before do
      allow(Signin::Register).to receive(:call)

      allow(Time).to receive(:now).and_return(time_now)
    end
    let(:time_now) { 1.second.ago }

    it 'invokes Signin register service' do
      expect(Signin::Register).to receive(:call).with(user:, installation_id:)

      assess
    end

    it 'returns an assessment' do
      assessment = assess

      expect(assessment.api_name).to eq(described_class::API_NAME)
      expect(assessment.timestamp).to eq(time_now)
    end
  end
end

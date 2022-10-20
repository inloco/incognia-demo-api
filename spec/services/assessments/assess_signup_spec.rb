require 'rails_helper'

RSpec.describe Assessments::AssessSignup, type: :service do
  subject(:assess) { described_class.(user:) }
  let(:user) { build(:user) }

  describe '.call' do
    before do
      allow(Signups::GetReassessment).to receive(:call)

      allow(Time).to receive(:now).and_return(time_now)
    end
    let(:time_now) { 1.second.ago }

    it 'invokes Signup get reassessment service' do
      expect(Signups::GetReassessment).to receive(:call).with(user:)

      assess
    end
  end
end

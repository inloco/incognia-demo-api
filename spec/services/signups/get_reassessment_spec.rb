require 'rails_helper'

RSpec.describe Signups::GetReassessment, type: :service do
  describe '.call' do
    subject(:get) { described_class.call(user:) }
    let(:user) { create(:user) }

    let(:signup_assessment) do
      build(:incognia_assessment, :signup, id: user.incognia_signup_id)
    end

    before do
      allow(IncogniaApi::Adapter).to receive(:new).and_return(adapter)
    end
    let(:adapter) do
      instance_double(
        IncogniaApi::Adapter,
        get_signup_assessment: signup_assessment
      )
    end

    it 'requests Incognia with incognia signup id' do
      expect(adapter).to receive(:get_signup_assessment)
        .with(signup_id: user.incognia_signup_id)

      get
    end

    it "returns the assessment" do
      expect(get).to eq(signup_assessment)
    end

    it 'logs the requested assessment' do
      expect { get }.to change(AssessmentLog, :count).by(1)

      created_log = AssessmentLog.last

      expect(created_log.api_name.to_sym).to eq(Signups::Constants::API_NAME)
      expect(created_log.incognia_id).to eq(signup_assessment.request_id)
      expect(created_log.incognia_signup_id).to eq(signup_assessment.id)
    end

    context 'when Incognia raises an error' do
      before do
        allow(adapter).to receive(:get_signup_assessment)
          .and_raise(Incognia::APIError, '')
      end

      it 'does not rescue it' do
        expect { get }.to raise_error(Incognia::APIError)
      end
    end
  end
end

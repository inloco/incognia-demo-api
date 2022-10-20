require 'rails_helper'

RSpec.describe Signups::GetReassessment, type: :service do
  describe '.call' do
    subject(:get) { described_class.call(user:) }
    let(:user) { create(:user) }

    let(:signup_assessment) { OpenStruct.new(id: user.incognia_signup_id) }

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

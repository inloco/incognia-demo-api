require 'rails_helper'

RSpec.describe Signups::GetReassessment, type: :service do
  describe '.call' do
    subject(:get) do
      described_class.call(incognia_signup_id: id)
    end
    let(:id) { signup.incognia_signup_id }

    let(:signup) { create(:signup) }
    let(:signup_assessment) { OpenStruct.new(id: signup.incognia_signup_id) }

    before do
      allow(IncogniaApi.instance).to receive(:get_signup_assessment)
        .with(signup_id: id)
        .and_return(signup_assessment)
    end

    it 'requests Incognia with incognia signup id' do
      expect(IncogniaApi.instance).to receive(:get_signup_assessment)
        .with(signup_id: id)
        .and_return(signup_assessment)

      get
    end

    it "returns the signup" do
      expect(get).to eq(signup)
    end

    context 'when does not exist signup with informed id' do
      let(:id) { SecureRandom.uuid }

      it 'raises not found error' do
        expect { get }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'does not request Incognia' do
        expect(IncogniaApi.instance).to_not receive(:get_signup_assessment)

        begin
          get
        rescue ActiveRecord::RecordNotFound
        end
      end
    end

    context 'when Incognia raises an error' do
      before do
        allow(IncogniaApi.instance).to receive(:get_signup_assessment)
          .and_raise(Incognia::APIError, '')
      end

      it 'does not rescue it' do
        expect { get }.to raise_error(Incognia::APIError)
      end
    end
  end
end

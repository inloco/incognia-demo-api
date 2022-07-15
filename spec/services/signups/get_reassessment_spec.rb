require 'rails_helper'

RSpec.describe Signups::GetReassessment, type: :service do
  describe '.call' do
    subject(:get) { described_class.call(incognia_signup_id: id) }
    let(:id) { user.incognia_signup_id }

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
      expect(adapter).to receive(:get_signup_assessment).with(signup_id: id)

      get
    end

    it "returns the user" do
      expect(get).to eq(user)
    end

    context 'when does not exist user with informed id' do
      let(:id) { SecureRandom.uuid }

      it 'raises not found error' do
        expect { get }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'does not request Incognia' do
        expect(adapter).to_not receive(:get_signup_assessment)

        begin
          get
        rescue ActiveRecord::RecordNotFound
        end
      end
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

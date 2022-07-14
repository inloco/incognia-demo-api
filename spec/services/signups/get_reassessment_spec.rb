require 'rails_helper'

RSpec.describe Signups::GetReassessment, type: :service do
  describe '.call' do
    subject(:get) { described_class.call(incognia_signup_id: id) }
    let(:id) { user.incognia_signup_id }

    let(:user) { create(:user) }
    let(:signup_assessment) { OpenStruct.new(id: user.incognia_signup_id) }

    before do
      allow_any_instance_of(IncogniaApi::Adapter)
        .to receive(:get_signup_assessment)
        .with(signup_id: id)
        .and_return(signup_assessment)
    end

    it 'requests Incognia with incognia signup id' do
      allow_any_instance_of(IncogniaApi::Adapter)
        .to receive(:get_signup_assessment)
        .with(signup_id: id)
        .and_return(signup_assessment)

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
        expect_any_instance_of(IncogniaApi::Adapter)
          .to_not receive(:get_signup_assessment)

        begin
          get
        rescue ActiveRecord::RecordNotFound
        end
      end
    end

    context 'when Incognia raises an error' do
      before do
        allow_any_instance_of(IncogniaApi::Adapter)
          .to receive(:get_signup_assessment)
          .and_raise(Incognia::APIError, '')
      end

      it 'does not rescue it' do
        expect { get }.to raise_error(Incognia::APIError)
      end
    end
  end
end

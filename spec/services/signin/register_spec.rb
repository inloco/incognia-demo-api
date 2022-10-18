require 'rails_helper'

RSpec.describe Signin::Register, type: :service do
  describe '.call' do
    subject(:register) { described_class.call(user:, installation_id:) }
    let(:user) { create(:user) }
    let(:installation_id) { SecureRandom.uuid }

    let(:login_assessment) { OpenStruct.new(id: SecureRandom.uuid) }

    before do
      allow(IncogniaApi::Adapter).to receive(:new).and_return(adapter)
    end
    let(:adapter) do
      instance_double(IncogniaApi::Adapter, register_login: login_assessment)
    end

    it 'requests Incognia with account and installation id' do
      expect(adapter).to receive(:register_login)
        .with(account_id: user.account_id, installation_id:)

      register
    end

    it "returns the assessment" do
      expect(register).to eq(login_assessment)
    end

    it 'logs the requested assessment' do
      expect { register }.to change(AssessmentLog, :count).by(1)

      created_log = AssessmentLog.last

      expect(created_log.api_name.to_sym).to eq(Signin::Constants::API_NAME)
      expect(created_log.incognia_id).to eq(login_assessment.id)
      expect(created_log.account_id).to eq(user.account_id)
      expect(created_log.installation_id).to eq(installation_id)
    end

    context 'when Incognia raises an error' do
      before do
        allow(adapter).to receive(:register_login)
          .and_raise(Incognia::APIError, '')
      end

      it 'does not rescue it' do
        expect { register }.to raise_error(Incognia::APIError)
      end
    end
  end
end

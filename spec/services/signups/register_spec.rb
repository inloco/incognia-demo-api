require 'rails_helper'

RSpec.describe Signups::Register, type: :service do
  describe '.call' do
    subject(:register) do
      described_class.call(installation_id:, structured_address:)
    end
    let(:installation_id) { SecureRandom.hex }
    let(:structured_address) { nil }

    let(:signup_assessment) do
      OpenStruct.new(
        id: SecureRandom.uuid,
        request_id: SecureRandom.uuid
      )
    end

    before do
      allow(IncogniaApi::Adapter).to receive(:new).and_return(adapter)
    end
    let(:adapter) do
      instance_double(
        IncogniaApi::Adapter,
        register_signup: signup_assessment
      )
    end

    it 'requests Incognia with installation id' do
      expect(adapter).to receive(:register_signup).with(installation_id: )

      register
    end

    it 'returns the assessment' do
      expect(register).to eq(signup_assessment)
    end

    it 'logs the requested assessment' do
      expect { register }.to change(AssessmentLog, :count).by(1)

      created_log = AssessmentLog.last

      expect(created_log.api_name.to_sym).to eq(Signups::Constants::API_NAME)
      expect(created_log.incognia_id).to eq(signup_assessment.request_id)
      expect(created_log.incognia_signup_id).to eq(signup_assessment.id)
    end

    context 'when address is informed' do
      let(:structured_address) { address }
      let(:address) do
        {
          country_name: Faker::Address.country,
          country_code: Faker::Address.country_code,
          state: Faker::Address.state,
          city: Faker::Address.city,
          borough: Faker::Lorem.word,
          street: Faker::Address.street_name,
          number: Faker::Address.building_number,
          postal_code: Faker::Address.zip_code
        }
      end

      it 'requests Incognia w/ installation_id and address w/ default locale' do
        expected_address = Incognia::Address::Structured.new(**address)

        allow(adapter).to receive(:register_signup) do |args|
            expect(args[:installation_id]).to eq(installation_id)
            expect(args[:address].to_hash).to eq(expected_address.to_hash)
          end.and_return(signup_assessment)

        register
      end
    end

    context 'when Incognia raises an error' do
      before do
        allow(adapter).to receive(:register_signup)
          .and_raise(Incognia::APIError, '')
      end

      it 'does not rescue it' do
        expect { register }.to raise_error(Incognia::APIError)
      end
    end
  end
end

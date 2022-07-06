require 'rails_helper'

RSpec.describe Signups::Create, type: :service do
  describe '.call' do
    subject(:create) { described_class.call(params) }
    let(:params) { { installation_id: installation_id } }

    let(:installation_id) { SecureRandom.uuid }
    let(:signup_assessment) { OpenStruct.new(id: SecureRandom.uuid) }

    before do
      allow(IncogniaApi.instance).to receive(:register_signup)
        .with(hash_including(installation_id: installation_id))
        .and_return(signup_assessment)
    end

    it 'requests Incognia with installation_id' do
      expect(IncogniaApi.instance).to receive(:register_signup)
        .with(installation_id: installation_id)
        .and_return(signup_assessment)

      create
    end

    it "creates a signup" do
      expect { create }.to change(Signup, :count).by(1)

      created_signup = Signup.last
      expect(created_signup.incognia_signup_id).to eq(signup_assessment.id)
    end

    it "returns created signup" do
      created_signup = create

      expect(created_signup).to eq(Signup.last)
    end

    context 'when address is informed' do
      before { params.merge!(address: address) }
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
      let(:enriched_address) do
        Incognia::Address::Structured.new(
          **address.merge(locale: described_class::EN_US_LOCALE)
        )
      end

      it "also stores the address along with the signup" do
        created_signup = create

        expect(
          created_signup.address.deep_symbolize_keys
        ).to eq(structured_address: address)
      end

      it 'requests Incognia w/ installation_id and address w/ default locale' do
        allow(IncogniaApi.instance).to receive(:register_signup) do |args|
          expect(args[:installation_id]).to eq(installation_id)
          expect(args[:address].to_hash).to eq(enriched_address.to_hash)
        end.and_return(signup_assessment)

        create
      end
    end

    context 'when Incognia raises an error' do
      before do
        allow(IncogniaApi.instance).to receive(:register_signup)
          .and_raise(Incognia::APIError, '')
      end

      it 'does not rescue it' do
        expect { create }.to raise_error(Incognia::APIError)
      end
    end
  end
end

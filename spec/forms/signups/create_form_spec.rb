require 'rails_helper'

RSpec.describe Signups::CreateForm, type: :model do
  context 'validations' do
    it { should validate_presence_of(:account_id) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:installation_id) }
    it { should allow_value(Faker::Internet.email).for(:email) }
    it { should_not allow_value('random@').for(:email) }
  end

  describe '#submit' do
    subject(:submit) { described_class.new(params).submit }

    context 'when attributes are valid' do
      let(:params) do
        {
          account_id: account_id,
          email: email,
          installation_id: installation_id,
        }
      end
      let(:account_id) { SecureRandom.uuid }
      let(:email) { Faker::Internet.email }
      let(:installation_id) { SecureRandom.uuid }

      before do
        allow(IncogniaApi.instance).to receive(:register_signup)
          .with(hash_including(installation_id: installation_id))
          .and_return(signup_assessment)
      end
      let(:signup_assessment) { OpenStruct.new(id: SecureRandom.uuid) }

      it 'requests Incognia with installation_id' do
        expect(IncogniaApi.instance).to receive(:register_signup)
          .with(installation_id: installation_id)
          .and_return(signup_assessment)

        submit
      end

      it "creates a signup" do
        expect { submit }.to change(Signup, :count).by(1)

        created_signup = Signup.last
        expect(created_signup.account_id).to eq(account_id)
        expect(created_signup.email).to eq(email)
        expect(created_signup.incognia_signup_id).to eq(signup_assessment.id)
      end

      it "returns created signup" do
        created_signup = submit

        expect(created_signup).to eq(Signup.last)
      end

      context 'when address is informed' do
        before { params.merge!(structured_address: address) }
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
          created_signup = submit

          expect(
            created_signup.address.deep_symbolize_keys
          ).to eq(structured_address: address)
        end

        it 'requests Incognia w/ installation_id and address w/ default locale' do
          allow(IncogniaApi.instance).to receive(:register_signup) do |args|
            expect(args[:installation_id]).to eq(installation_id)
            expect(args[:address].to_hash).to eq(enriched_address.to_hash)
          end.and_return(signup_assessment)

          submit
        end
      end

      context 'when Incognia raises an error' do
        before do
          allow(IncogniaApi.instance).to receive(:register_signup)
            .and_raise(Incognia::APIError, '')
        end

        it 'does not rescue it' do
          expect { submit }.to raise_error(Incognia::APIError)
        end
      end
    end

    context 'when attributes are invalid' do
      let(:params) { {} }

      it 'does not request Incognia' do
        expect(IncogniaApi.instance).to_not receive(:register_signup)

        submit
      end

      it 'does not create a signup' do
        expect { submit }.to_not change(Signup, :count)
      end

      it 'returns falsy' do
        expect(submit).to be_falsy
      end
    end
  end
end

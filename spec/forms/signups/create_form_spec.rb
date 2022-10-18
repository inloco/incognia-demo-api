require 'rails_helper'

RSpec.describe Signups::CreateForm, type: :model do
  subject(:form) { described_class.new(attrs) }
  let(:attrs) { {} }

  context 'validations' do
    it { should validate_presence_of(:account_id) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:installation_id) }
    it { should allow_value(Faker::Internet.email).for(:email) }
    it { should_not allow_value('random@').for(:email) }

    describe 'email uniqueness' do
      let(:attrs) do
        {
          account_id: SecureRandom.uuid,
          email: email,
          installation_id: SecureRandom.uuid,
        }
      end

      context 'when user with same email already exists' do
        let(:email) { existent_user.email }
        let(:existent_user) { create(:user) }

        it 'is expected to validate that :email is unique' do
          expect(form).to be_invalid
          expect(form.errors).to have_key(:email)
          expect(form.errors[:email]).to include(I18n.t('errors.messages.taken'))
        end
      end
    end
  end

  describe '#submit' do
    subject(:submit) { form.submit }

    before do
      allow(Signups::Register).to receive(:call).and_return(signup_assessment)
    end
    let(:signup_assessment) { OpenStruct.new(id: SecureRandom.uuid) }

    context 'when attributes are valid' do
      let(:attrs) { { account_id:, email:, installation_id: } }
      let(:account_id) { SecureRandom.uuid }
      let(:email) { Faker::Internet.email }
      let(:installation_id) { SecureRandom.uuid }

      it 'register signup with installation_id' do
        expect(Signups::Register).to receive(:call).with(installation_id:)

        submit
      end

      it "creates a user" do
        expect { submit }.to change(User, :count).by(1)

        created_user = User.last
        expect(created_user.account_id).to eq(account_id)
        expect(created_user.email).to eq(email)
        expect(created_user.address).to be_nil
        expect(created_user.incognia_signup_id).to eq(signup_assessment.id)
      end

      it "returns created user" do
        created_user = submit

        expect(created_user).to eq(User.last)
      end

      context 'when address is informed' do
        before { attrs.merge!(structured_address: address) }
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
          address.merge(locale: described_class::EN_US_LOCALE)
        end

        it "also stores the address along with the signup" do
          created_signup = submit

          expect(
            created_signup.address.deep_symbolize_keys
          ).to eq(structured_address: enriched_address)
        end

        it 'register signup w/ installation_id and address w/ default locale' do
          allow(Signups::Register).to receive(:call) do |args|
              expect(args[:installation_id]).to eq(installation_id)
              expect(args[:structured_address].to_hash).to eq(
                enriched_address.to_hash
              )
            end.and_return(signup_assessment)

          submit
        end
      end

      context 'when Incognia raises an error' do
        before do
          allow(Signups::Register).to receive(:call)
            .and_raise(Incognia::APIError, '')
        end

        it 'does not rescue it' do
          expect { submit }.to raise_error(Incognia::APIError)
        end
      end

      context 'when race condition occurs' do
        before do
          allow(User).to receive(:create!)
            .and_raise(ActiveRecord::RecordNotUnique)
        end

        it 'returns falsy' do
          expect(submit).to be_falsy
        end

        it 'is expected to validate that :email is unique' do
          submit

          expect(form.errors).to have_key(:email)
          expect(form.errors[:email]).to include(I18n.t('errors.messages.taken'))
        end
      end
    end

    context 'when attributes are invalid' do
      let(:attrs) { {} }

      it 'does not register signup' do
        expect(Signups::Register).to_not receive(:call)

        submit
      end

      it 'does not create a user' do
        expect { submit }.to_not change(User, :count)
      end

      it 'returns falsy' do
        expect(submit).to be_falsy
      end
    end
  end
end

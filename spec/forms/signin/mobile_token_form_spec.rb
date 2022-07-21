require 'rails_helper'

RSpec.describe Signin::MobileTokenForm, type: :model do
  subject(:form) { described_class.new(attrs) }
  let(:attrs) { { email: user.email } }
  let(:user) { create(:user) }

  context 'validations' do
    it { should validate_presence_of(:email) }

    describe 'user existence' do
      let(:attrs) { { email: Faker::Internet.email } }

      it 'is expected to validate that :email is invalid' do
        expect(form).to be_invalid
        expect(form.errors).to have_key(:email)
        expect(form.errors[:email]).to include(I18n.t('errors.messages.invalid'))
      end
    end
  end

  describe '#submit' do
    subject(:submit) { form.submit }

    before do
      allow(Signin::GenerateSigninCode).to receive(:call)
        .and_return(generated_code)
    end
    let(:generated_code) { build(:signin_code).code }

    context 'when attributes are valid' do
      it 'generates signin code' do
        expect(Signin::GenerateSigninCode).to receive(:call).with(user:)

        submit
      end

      it 'returns the generated signin code' do
        expect(submit).to eq(generated_code)
      end
    end

    context 'when attributes are invalid' do
      let(:attrs) { {} }

      it 'does not generate signin code' do
        expect(Signin::GenerateSigninCode).to_not receive(:call)

        submit
      end

      it 'returns falsy' do
        expect(submit).to be_falsy
      end
    end
  end
end

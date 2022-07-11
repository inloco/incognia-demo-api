require 'rails_helper'

RSpec.describe Signin::OtpForm, type: :model do
  subject(:form) { described_class.new(attrs) }
  let(:attrs) { { user: signin_code.user, code: signin_code.code } }
  let(:signin_code) { create(:signin_code) }

  context 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:code) }

    describe 'code existence' do
      before { attrs.merge!(code: Faker::Lorem.word) }

      it 'is expected to validate that :code is invalid' do
        expect(form).to be_invalid
        expect(form.errors).to have_key(:code)
        expect(form.errors[:code]).to include(I18n.t('errors.messages.invalid'))
      end
    end

    describe 'code usage' do
      before { signin_code.update(used_at: 5.hours.ago) }

      it 'is expected to validate that :code is already used' do
        expect(form).to be_invalid
        expect(form.errors).to have_key(:code)
        expect(form.errors[:code]).to include(
          I18nHelpers.model_attribute_error(
            klass: form.class,
            attribute: :code,
            error_key: :already_used
          )
        )
      end
    end

    describe 'code expiration' do
      before { signin_code.update(expires_at: 5.hours.ago) }

      it 'is expected to validate that :code is expired' do
        expect(form).to be_invalid
        expect(form.errors).to have_key(:code)
        expect(form.errors[:code]).to include(
          I18nHelpers.model_attribute_error(
            klass: form.class,
            attribute: :code,
            error_key: :expired
          )
        )
      end
    end
  end

  describe '#submit' do
    subject(:submit) { form.submit }

    context 'when attributes are valid' do
      it 'updates sigin code used timestamp' do
        expect { submit }.to change { signin_code.reload.used_at }
      end

      it 'returns the logged in user' do
        expect(submit).to eq(signin_code.user)
      end
    end

    context 'when attributes are invalid' do
      let(:attrs) { {} }

      it 'does not update sigin code used timestamp' do
        expect { submit }.to_not change { signin_code.used_at }
      end

      it 'returns falsy' do
        expect(submit).to be_falsy
      end
    end
  end
end

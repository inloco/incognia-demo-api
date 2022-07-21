require 'rails_helper'

RSpec.describe Signin::OtpForm, type: :model do
  subject(:form) { described_class.new(attrs) }
  let(:attrs) { { user: signin_code.user, code: signin_code.code } }
  let(:signin_code) { create(:signin_code) }

  context 'validations' do
    it { should validate_presence_of(:user) }

    it_behaves_like 'form with sign in code validations'
  end

  describe '#submit' do
    subject(:submit) { form.submit }

    context 'when attributes are valid' do
      it 'updates signin code used timestamp' do
        expect { submit }.to change { signin_code.reload.used_at }
      end

      it 'returns the logged in user' do
        expect(submit).to eq(signin_code.user)
      end
    end

    context 'when attributes are invalid' do
      let(:attrs) { {} }

      it 'does not update signin code used timestamp' do
        expect { submit }.to_not change { signin_code.used_at }
      end

      it 'returns falsy' do
        expect(submit).to be_falsy
      end
    end
  end
end

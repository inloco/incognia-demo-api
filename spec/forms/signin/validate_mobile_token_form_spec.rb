require 'rails_helper'

RSpec.describe Signin::ValidateMobileTokenForm, type: :model do
  subject(:form) { described_class.new(attrs) }
  let(:attrs) { { user:, code: signin_code.code } }
  let(:user) { create(:user) }
  let(:signin_code) { create(:signin_code, user:) }

  context 'validations' do
    it { should validate_presence_of(:user) }

    it_behaves_like 'form with sign in code validations'
  end

  describe '#submit' do
    subject(:submit) { form.submit }

    context 'when attributes are valid' do
      before do
        allow(Signin::GenerateSigninCode).to receive(:call)
          .and_return(generated_code)
      end
      let(:generated_code) { build(:signin_code).code }

      it 'updates signin code used timestamp' do
        expect { submit }.to change { signin_code.reload.used_at }
      end

      it 'generates a new signin code with fast expiration' do
        expect(Signin::GenerateSigninCode).to receive(:call).with(
          user:,
          expiration_time: described_class::EXPIRATION_TIME_IN_SECONDS
        )

        submit
      end

      it 'returns the new generated code' do
        expect(submit).to eq(generated_code)
      end

      context 'and the code generation raises an error' do
        before do
          allow(Signin::GenerateSigninCode).to receive(:call)
            .and_raise(ActiveRecord::ConnectionTimeoutError)
        end

        it 'leaves the signin code unused' do
          begin
          submit
          rescue ActiveRecord::ConnectionTimeoutError
          end

          signin_code.reload
          expect(signin_code.used_at).to be_nil
        end
      end
    end

    context 'when attributes are invalid' do
      let(:attrs) { {} }

      it 'does not update signin code used timestamp' do
        expect { submit }.to_not change { signin_code.used_at }
      end

      it 'does not generate a new signin code' do
        expect(Signin::GenerateSigninCode).to_not receive(:call)

        submit
      end

      it 'returns falsy' do
        expect(submit).to be_falsy
      end
    end
  end

  context '#signin_code' do
    it 'returns the signin code correspondent to informed code' do
      expect(form.signin_code).to eq(signin_code)
    end
  end
end

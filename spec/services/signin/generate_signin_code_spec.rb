require 'rails_helper'

RSpec.describe Signin::GenerateSigninCode, type: :service do
  describe '.call' do
    subject(:generate) { described_class.call(**attrs) }
    let(:attrs) { { user: } }
    let(:user) { create(:user) }

    before do
      allow(SecureRandom).to receive(:base64).with(described_class::OTP_LENGTH).
        and_return(code)
    end
    let(:code) { Faker::Alphanumeric.alphanumeric }

    it 'creates a signin code associated with the user' do
      expect { generate }.to change(SigninCode, :count).by(1)

      generated_code = SigninCode.last
      expect(generated_code.code).to eq(code)
      expect(generated_code.user).to eq(user)
      expect(generated_code.expires_at). to be_within(
        1.second
      ).of(
        Time.now + described_class::EXPIRATION_TIME_IN_MINUTES.minutes
      )
    end

    it "returns the generated code" do
      expect(generate).to eq(code)
    end

    context 'when expiration time is informed' do
      let(:attrs) { { user:, expiration_time: } }
      let(:expiration_time) { rand(10).minutes }

      it 'creates a signin code considering it' do
        expect { generate }.to change(SigninCode, :count).by(1)

        generated_code = SigninCode.last
        expect(generated_code.expires_at).to be_within(1.second)
          .of(Time.now + expiration_time)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Signin::GenerateSigninCode, type: :service do
  describe '.call' do
    subject(:generate) do
      described_class.call(user: user)
    end
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
  end
end

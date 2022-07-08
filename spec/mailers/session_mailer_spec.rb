require "rails_helper"

RSpec.describe SessionMailer, type: :mailer do
  subject(:mailer) { described_class }

  describe '#otp_email' do
    subject(:mail) do
      mailer.otp_email(recipient: recipient, otp_code: otp_code).deliver_now
    end
    let(:recipient) { Faker::Internet.email }
    let(:otp_code) { SecureRandom.base64(20) }

    it 'sends to the recipient' do
      expect(mail.to).to eq([recipient])
    end

    it 'correctly sets the subject' do
      expect(mail.subject).to eq('Temporary Incognia sign in code')
    end

    it 'assigns the otp code' do
      expect(mail.body.encoded).to include(otp_code)
    end
  end
end

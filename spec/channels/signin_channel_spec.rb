require 'rails_helper'

RSpec.describe SigninChannel, type: :channel do
  describe '#subscribed' do
    let(:signin_code) { create(:signin_code) }

    context 'when informed code exists' do
      it 'streams for this code' do
        subscribe code: signin_code.code

        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_for(signin_code)
      end
    end

    context 'when informed code does not exist' do
      it 'rejects' do
        subscribe code: build(:signin_code).code

        expect(subscription).to be_rejected
      end
    end
  end
end

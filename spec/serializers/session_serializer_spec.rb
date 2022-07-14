require 'rails_helper'

RSpec.describe SessionSerializer, type: :serializer do
  subject(:serialized) { described_class.new(user: user).to_hash }
  let(:user) { create(:user) }

  it 'serializes login with its user info' do
    expect(serialized).to eq(
      {
        'signup_id' => user.incognia_signup_id,
        'signup_timestamp' => user.created_at.to_i,
        'structured_address' => user.address['structured_address']
      }
    )
  end

  context 'when user does not have address' do
    before { user.update(address: nil) }

    it 'serializes login with its user info without address' do
      expect(serialized).to eq(
        {
          'signup_id' => user.incognia_signup_id,
          'signup_timestamp' => user.created_at.to_i,
        }
      )
    end
  end
end

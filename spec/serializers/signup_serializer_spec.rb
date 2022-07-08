require 'rails_helper'

RSpec.describe SignupSerializer, type: :serializer do
  subject(:serialized) { described_class.new(user: user).to_hash }
  let(:user) { build(:user) }

  it 'serializes signup' do
    expect(serialized).to eq('id' => user.incognia_signup_id)
  end
end

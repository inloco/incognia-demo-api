require 'rails_helper'

RSpec.describe SignupSerializer, type: :serializer do
  subject(:serialized) { described_class.new(signup: signup).to_hash }
  let(:signup) { build(:signup) }

  it 'serializes signup' do
    expect(serialized).to eq('id' => signup.incognia_signup_id)
  end
end

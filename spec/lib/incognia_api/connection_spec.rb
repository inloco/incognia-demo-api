require 'rails_helper'

RSpec.describe IncogniaApi::Connection, type: :lib do
  describe '.instance' do
    before do
      allow(ENV).to receive(:[]).with('INCOGNIA_CLIENT_ID').and_return(client_id)
      allow(ENV).to receive(:[]).with('INCOGNIA_SECRET')
        .and_return(client_secret)

    end
    let(:client_id) { SecureRandom.uuid }
    let(:client_secret) { SecureRandom.uuid }

    it 'initializes Incognia api library with propert env vars' do
      expect(Incognia::Api).to receive(:new).with(client_id:, client_secret:)

      described_class.instance.api
    end

    it 'returns the same instance of Connection' do
      expect(described_class.instance).to be_an(described_class)
      expect(described_class.instance).to eq(described_class.instance)
    end
  end
end

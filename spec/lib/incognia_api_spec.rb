require 'rails_helper'

RSpec.describe IncogniaApi, type: :lib do
  subject { described_class.instance }

  describe '.instance' do
    before do
      allow(ENV).to receive(:[]).with('INCOGNIA_CLIENT_ID').and_return(client_id)
      allow(ENV).to receive(:[]).with('INCOGNIA_SECRET')
        .and_return(client_secret)

    end
    let(:client_id) { SecureRandom.uuid }
    let(:client_secret) { SecureRandom.uuid }

    it 'initializes Incognia api library with propert env vars' do
      expect(Incognia::Api).to receive(:new)
        .with(client_id: client_id, client_secret: client_secret)

      IncogniaApi.instance.incognia_api
    end

    it 'returns the same instance of IncogniaApi' do
      expect(IncogniaApi.instance).to be_an(IncogniaApi)
      expect(IncogniaApi.instance).to eq(IncogniaApi.instance)
    end
  end

  it { should delegate_method(:register_signup).to(:incognia_api) }
  it { should delegate_method(:get_signup_assessment).to(:incognia_api) }
  it { should delegate_method(:register_login).to(:incognia_api) }
end

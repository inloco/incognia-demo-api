require 'rails_helper'

RSpec.describe IncogniaApi, type: :lib do
  before do
    allow(ENV).to receive(:[]).with('INCOGNIA_CLIENT_ID').and_return(client_id)
    allow(ENV).to receive(:[]).with('INCOGNIA_SECRET')
      .and_return(client_secret)

    allow(Incognia::Api).to receive(:new)
      .with(client_id: client_id, client_secret: client_secret)
      .and_return(api)
  end
  let(:api) { instance_double(Incognia::Api) }
  let(:client_id) { SecureRandom.uuid }
  let(:client_secret) { SecureRandom.uuid }

  describe '.instance' do
    it 'returns the same instance of IncogniaApi' do
      expect(IncogniaApi.instance).to be_an(IncogniaApi)
      expect(IncogniaApi.instance).to eq(IncogniaApi.instance)
    end
  end

  describe '#register_signup' do
    # Using clone to avoid mock leaking due to singleton
    subject(:wrapper) { described_class.clone.instance }
    let(:installation_id) { SecureRandom.uuid }

    it 'delegates to Incognia::Api' do
      expect(api).to receive(:register_signup)
        .with(installation_id: installation_id)

      wrapper.register_signup(installation_id: installation_id)
    end
  end

  describe '#get_signup_assessment' do
    # Using clone to avoid mock leaking due to singleton
    subject(:wrapper) { described_class.clone.instance }
    let(:signup_id) { SecureRandom.uuid }

    it 'delegates to Incognia::Api' do
      expect(api).to receive(:get_signup_assessment)
        .with(signup_id: signup_id)

      wrapper.get_signup_assessment(signup_id: signup_id)
    end
  end
end

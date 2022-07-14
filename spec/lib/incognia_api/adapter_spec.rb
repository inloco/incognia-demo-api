require 'rails_helper'

RSpec.describe IncogniaApi::Adapter, type: :lib do
  subject { described_class.new }

  it { should delegate_method(:register_signup).to(:api) }
  it { should delegate_method(:get_signup_assessment).to(:api) }
  it { should delegate_method(:register_login).to(:api) }

  context 'connection initialization' do
    it 'uses incognia connection' do
      expect(IncogniaApi::Connection.instance).to receive(:api)
        .and_return(instance_double(Incognia::Api, register_signup: nil))

      subject.register_signup(installation_id: SecureRandom.uuid)
    end
  end
end

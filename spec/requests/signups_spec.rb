require 'rails_helper'

RSpec.describe "Signups", type: :request do
  shared_examples_for 'handle Incognia API errors' do
    context 'when API returns 404' do
      before do
        allow(incognia_api).to receive(method)
          .and_raise(Incognia::APIError.new('', status: 404))
      end

      it "returns http not found" do
        dispatch_request

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when API returns 400' do
      before do
        allow(incognia_api).to receive(method)
          .and_raise(Incognia::APIError.new('', status: 400, body: error_message))
      end
      let(:error_message) { { errors: 'Some error'}.to_json }

      it "returns http 422" do
        dispatch_request

        expect(response).to have_http_status(422)
      end
    end

    context 'when API returns other error' do
      before do
        allow(incognia_api).to receive(method)
          .and_raise(Incognia::APIError.new(''))
      end

      it "returns http internal error" do
        dispatch_request

        expect(response).to have_http_status(:error)
      end
    end
  end

  describe "GET /show" do
    subject(:dispatch_request) { get "/signups/#{id}" }

    let(:id) { SecureRandom.uuid }
    let(:signup) { OpenStruct.new(id: id) }

    before do
      allow(Incognia::Api).to receive(:new).and_return(incognia_api)

      allow(incognia_api).to receive(:get_signup_assessment)
        .with(signup_id: id)
        .and_return(signup)
    end
    let(:incognia_api) { instance_double(Incognia::Api) }

    it 'requests Incognia with informed id' do
      expect(incognia_api).to receive(:get_signup_assessment)
        .with(signup_id: id)
        .and_return(signup)

      dispatch_request
    end

    it "returns http success" do
      dispatch_request

      expect(response).to have_http_status(:success)
    end

    it "returns signup as JSON" do
      dispatch_request

      expect(response.body).to eq(signup.to_h.to_json)
    end

    it_behaves_like 'handle Incognia API errors' do
      let(:method) { :get_signup_assessment }
    end
  end

  describe "POST /create" do
    subject(:dispatch_request) do
      post "/signups", params: { structured_address: address }, headers: headers
    end
    let(:address) do
      {
        country_name:"United States of America",
        country_code:"US",
        state:"NY",
        city:"New York City",
        borough:"Manhattan",
        street:"W 34th St.",
        number:"20",
        postal_code:"10001"
      }
    end
    let(:headers) do
      {
        "ACCEPT" => "application/json",
        SignupsController::INCOGNIA_INSTALLATION_ID_HEADER => installation_id
      }
    end
    let(:installation_id) { SecureRandom.hex }

    let(:signup) { OpenStruct.new(id: SecureRandom.uuid) }

    before do
      allow(Incognia::Api).to receive(:new).and_return(incognia_api)

      allow(incognia_api).to receive(:register_signup)
        .with(
          installation_id: installation_id,
          address: hash_including(address)
        )
        .and_return(signup)
    end
    let(:incognia_api) { instance_double(Incognia::Api) }

    it 'requests Incognia with default locale' do
      enriched_address = address.merge(locale: SignupsController::EN_US_LOCALE)

      expect(incognia_api).to receive(:register_signup)
        .with(installation_id: installation_id, address: enriched_address)
        .and_return(signup)

      dispatch_request
    end

    it "returns http success" do
      dispatch_request

      expect(response).to have_http_status(:success)
    end

    it "returns registered signup as JSON" do
      dispatch_request

      expect(response.body).to eq(signup.to_h.to_json)
    end

    it_behaves_like 'handle Incognia API errors' do
      let(:method) { :register_signup }
    end
  end
end

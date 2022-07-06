require 'rails_helper'

RSpec.describe "Signups", type: :request do
  shared_examples_for 'handle Incognia API errors' do
    context 'when API returns 404' do
      before do
        allow(service).to receive(:call)
          .and_raise(Incognia::APIError.new('', status: 404))
      end

      it "returns http not found" do
        dispatch_request

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when API returns 400' do
      before do
        allow(service).to receive(:call)
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
        allow(service).to receive(:call)
          .and_raise(Incognia::APIError.new(''))
      end

      it "returns http internal error" do
        dispatch_request

        expect(response).to have_http_status(:error)
      end
    end
  end

  describe "GET /show" do
    subject(:dispatch_request) { get "/signups/#{signup.incognia_signup_id}" }
    let(:signup) { create(:signup) }

    before do
      allow(Signups::GetReassessment).to receive(:call)
        .with(incognia_signup_id: signup.incognia_signup_id)
        .and_return(signup)
    end

    it "invokes singups reassessment service" do
      allow(Signups::GetReassessment).to receive(:call)
        .with(incognia_signup_id: signup.incognia_signup_id)
        .and_return(signup)

      dispatch_request
    end

    it "returns http success" do
      dispatch_request

      expect(response).to have_http_status(:success)
    end

    it "returns signup as JSON" do
      dispatch_request

      expect(response.body).to eq({ id: signup.incognia_signup_id }.to_json)
    end

    it_behaves_like 'handle Incognia API errors' do
      let(:service) { Signups::GetReassessment }
    end
  end

  describe "POST /create" do
    subject(:dispatch_request) do
      post "/signups", params: params, headers: headers
    end
    let(:params) { {} }
    let(:headers) do
      {
        "ACCEPT" => "application/json",
        SignupsController::INCOGNIA_INSTALLATION_ID_HEADER => installation_id
      }
    end
    let(:installation_id) { SecureRandom.hex }

    let(:signup) { create(:signup) }

    before do
      allow(Signups::Create).to receive(:call)
        .with(installation_id: installation_id)
        .and_return(signup)
    end

    it "invokes singups create service" do
      expect(Signups::Create).to receive(:call)
        .with(installation_id: installation_id)

      dispatch_request
    end

    it "returns http success" do
      dispatch_request

      expect(response).to have_http_status(:success)
    end

    it "returns registered signup as JSON" do
      dispatch_request

      expect(response.body).to eq({ id: signup.incognia_signup_id }.to_json)
    end

    it_behaves_like 'handle Incognia API errors' do
      let(:service) { Signups::Create }
    end

    context 'when structured address is informed' do
      let(:params) { { structured_address: address } }
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

      it "invokes singups create service with address info" do
        expect(Signups::Create).to receive(:call)
          .with(installation_id: installation_id, address: address)
          .and_return(signup)

        dispatch_request
      end
    end
  end
end

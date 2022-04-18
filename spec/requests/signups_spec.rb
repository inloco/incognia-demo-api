require 'rails_helper'

RSpec.describe "Signups", type: :request do
  describe "GET /show" do
    subject(:request_signup) { get "/signups/#{id}" }

    let(:id) { SecureRandom.uuid }
    let(:signup) { OpenStruct.new(id: id) }

    before do
      allow(Incognia::Api).to receive(:new).and_return(incognia_api)

      allow(incognia_api).to receive(:get_signup_assessment)
        .with(signup_id: id)
        .and_return(signup)
    end
    let(:incognia_api) { instance_double(Incognia::Api) }

    it "returns http success" do
      request_signup

      expect(response).to have_http_status(:success)
    end

    it "returns signup as JSON" do
      request_signup

      expect(response.body).to eq(signup.to_h.to_json)
    end

    context 'when API returns 404' do
      before do
        allow(incognia_api).to receive(:get_signup_assessment)
          .with(signup_id: id)
          .and_raise(Incognia::APIError.new('', status: 404))
      end

      it "returns http not found" do
        request_signup

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when API returns other error' do
      before do
        allow(incognia_api).to receive(:get_signup_assessment)
          .with(signup_id: id)
          .and_raise(Incognia::APIError.new(''))
      end

      it "returns http internal error" do
        request_signup

        expect(response).to have_http_status(:error)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "Web::Sessions", type: :request do
  describe "GET /new" do
    let(:dispatch_request) { get '/web/sessions/new' }

    it "returns http success" do
      dispatch_request

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Sign in')
    end

    it "render Sign in form" do
      dispatch_request

      expect(response.body).to include('Sign in')
      expect(response.body).to include('form')
    end
  end

  describe "POST /create" do
    let(:dispatch_request) do
      post '/web/sessions', xhr: true, params: {
        signin_mobile_token_form: form_params
      }
    end
    let(:form_params) { { email: user.email } }
    let(:user) { create(:user) }

    it "returns http success" do
      dispatch_request

      expect(response).to have_http_status(:success)
    end

    it "render MFA authentication" do
      dispatch_request

      expect(response.body).to include('Two-Factor Authentication')
      expect(response.body).to include('data-controller="signin"')
      expect(response.body).to include('data-signin-code=')
      expect(response.body).to include('<svg')
    end

    context 'when params are invalid' do
      let(:form_params) { { email: Faker::Internet.email } }

      it "returns http success" do
        dispatch_request

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

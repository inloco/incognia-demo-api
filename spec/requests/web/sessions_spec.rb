require 'rails_helper'

RSpec.describe "Web::Sessions", type: :request do
  shared_examples_for 'not logged in action' do
    context 'when there is a current user' do
      include_context 'current user'

      it 'redirects to web root' do
        dispatch_request

        expect(response).to redirect_to(web_root_path)
      end
    end
  end

  describe "GET /new" do
    let(:dispatch_request) { get '/web/session/new' }

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

    it_behaves_like 'not logged in action'
  end

  describe "POST /create" do
    let(:dispatch_request) do
      post '/web/session', xhr: true, params: {
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

    it_behaves_like 'not logged in action'
  end

  describe "POST /validate_otp" do
    subject(:dispatch_request) { post "/web/session/validate_otp", params: }
    let(:params) { { email: user.email, code: } }
    let(:code) { signin_code.code }
    let(:user) { signin_code.user }
    let(:signin_code) { create(:signin_code) }

    context 'when validations succeed' do
      before do
        allow(Signin::OtpForm).to receive(:new).with(user:, code:)
          .and_return(form)
      end
      let(:form) { instance_double(Signin::OtpForm, errors: []) }

      it "invokes otp signin form" do
        expect(form).to receive(:submit)

        dispatch_request
      end

      context 'and the form returns the logged in user' do
        before { allow(form).to receive(:submit).and_return(user) }

        it "sets the user session" do
          expect_any_instance_of(Web::ApplicationController)
            .to receive(:set_user_session).with(user)

          dispatch_request
        end

        it "returns http success" do
          dispatch_request

          expect(response).to have_http_status(:success)
        end
      end

      context 'but the form returns nil' do
        before { allow(form).to receive(:submit).and_return(nil) }

        it "returns http unauthorized" do
          dispatch_request

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'when validations fails' do
      before do
        allow_any_instance_of(Signin::OtpForm).to receive(:submit)
          .and_return(nil)

        allow_any_instance_of(Signin::OtpForm).to receive(:errors)
          .and_return(form_errors)
      end
      let(:form_errors) do
        Signin::OtpForm
          .new
          .errors
          .tap { |e| e.add(attribute, message) }
      end
      let(:attribute) { :user }
      let(:message) { 'cant be blank' }

      it "returns http unprocessable entity" do
        dispatch_request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns detailed errors" do
        dispatch_request

        parsed_body = JSON.parse(response.body).deep_symbolize_keys
        expect(parsed_body).to have_key(:errors)
        expect(parsed_body.dig(:errors, attribute)).to include(message)
      end
    end
  end

  describe "DELETE /destroy" do
    subject(:dispatch_request) { delete "/web/session" }

    it 'resets user session' do
      expect_any_instance_of(Web::SessionsController).to receive(:reset_session)

      dispatch_request
    end

    it 'redirects to root' do
      dispatch_request

      expect(response).to redirect_to(web_root_path)
    end
  end
end

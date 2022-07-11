require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "POST /create" do
    subject(:dispatch_request) { post "/signin", params:, headers: }
    let(:params) { { account_id: user.account_id } }
    let(:user) { create(:user) }
    let(:headers) do
      {
        "ACCEPT" => "application/json",
        SignupsController::INCOGNIA_INSTALLATION_ID_HEADER => installation_id
      }
    end
    let(:installation_id) { SecureRandom.hex }


    context 'when validations succeed' do
      before do
        allow(Signin::PasswordlessForm).to receive(:new)
          .with(user:, installation_id:)
          .and_return(form)
      end
      let(:form) { instance_double(Signin::PasswordlessForm, errors: []) }

      context 'and the form returns the user' do
        before { allow(form).to receive(:submit).and_return(user) }

        it "invokes passwordless signin form" do
          allow(Signin::PasswordlessForm).to receive(:new)
            .with(user:, installation_id:)
            .and_return(form)

          expect(form).to receive(:submit)

          dispatch_request
        end

        it "returns http success" do
          dispatch_request

          expect(response).to have_http_status(:success)
        end

        it "returns registered signup as JSON" do
          dispatch_request

          expect(response.body).to eq(SessionSerializer.new(user:).to_json)
        end
      end

      context 'but the form returns nil' do
        before { allow(form).to receive(:submit).and_return(nil) }

        it "returns http unauthorized" do
          dispatch_request

          expect(response).to have_http_status(:unauthorized)
        end

        it "returns otp required message" do
          dispatch_request

          parsed_body = JSON.parse(response.body).deep_symbolize_keys
          expect(parsed_body).to have_key(:otp_required)
          expect(parsed_body.dig(:otp_required)).to eq(true)
        end
      end

      it_behaves_like 'handle Incognia API errors' do
        let(:service) { form }
        let(:method) { :submit }
      end
    end

    context 'when validations fails' do
      before do
        allow_any_instance_of(Signin::PasswordlessForm).to receive(:submit)
          .and_return(nil)

        allow_any_instance_of(Signin::PasswordlessForm).to receive(:errors)
          .and_return(form_errors)
      end
      let(:form_errors) do
        Signin::PasswordlessForm
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
end

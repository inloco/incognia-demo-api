require 'rails_helper'

RSpec.describe "Signups", type: :request do
  describe "GET /show" do
    subject(:dispatch_request) { get "/signups/#{user.incognia_signup_id}" }
    let(:user) { create(:user) }

    before do
      allow(Signups::GetReassessment).to receive(:call)
        .with(incognia_signup_id: user.incognia_signup_id)
        .and_return(user)
    end

    it "invokes singups reassessment service" do
      allow(Signups::GetReassessment).to receive(:call)
        .with(incognia_signup_id: user.incognia_signup_id)
        .and_return(user)

      dispatch_request
    end

    it "returns http success" do
      dispatch_request

      expect(response).to have_http_status(:success)
    end

    it "returns signup as JSON" do
      dispatch_request

      expect(response.body).to eq(SignupSerializer.new(user:).to_json)
    end

    it_behaves_like 'handle Incognia API errors' do
      let(:service) { Signups::GetReassessment }
      let(:method) { :call }
    end
  end

  describe "POST /create" do
    subject(:dispatch_request) { post "/signups", params:, headers: }
    let(:params) { { account_id:, email: } }
    let(:account_id) { SecureRandom.uuid }
    let(:email) { Faker::Internet.email }
    let(:headers) do
      {
        "ACCEPT" => "application/json",
        SignupsController::INCOGNIA_INSTALLATION_ID_HEADER => installation_id
      }
    end
    let(:installation_id) { SecureRandom.hex }


    context 'when validations succeed' do
      before do
        allow(Signups::CreateForm).to receive(:new)
          .with(params.merge(installation_id:))
          .and_return(form)

        allow(form).to receive(:submit).and_return(user)
      end
      let(:form) { instance_double(Signups::CreateForm) }
      let(:user) { create(:user) }

      it "invokes singups create form" do
        allow(Signups::CreateForm).to receive(:new)
          .with(params.merge(installation_id:))
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

        expect(response.body).to eq(SignupSerializer.new(user:).to_json)
      end

      it_behaves_like 'handle Incognia API errors' do
        let(:service) { form }
        let(:method) { :submit }
      end

      context 'when structured address is informed' do
        before { params.merge!(structured_address: address) }

        let(:address) do
          {
            country_name: Faker::Address.country,
            country_code: Faker::Address.country_code,
            state: Faker::Address.state,
            city: Faker::Address.city,
            borough: Faker::Lorem.word,
            street: Faker::Address.street_name,
            number: Faker::Address.building_number,
            postal_code: Faker::Address.zip_code
          }
        end

        it "invokes singups create form with address info" do
          expect(Signups::CreateForm).to receive(:new)
            .with(params.merge(installation_id:))
            .and_return(form)

          expect(form).to receive(:submit)

          dispatch_request
        end
      end
    end

    context 'when validations fails' do
      before do
        allow_any_instance_of(Signups::CreateForm).to receive(:submit)
          .and_return(nil)

        allow_any_instance_of(Signups::CreateForm).to receive(:errors)
          .and_return(form_errors)
      end
      let(:form_errors) do
        Signups::CreateForm
          .new
          .errors
          .tap { |e| e.add(attribute, message) }
      end
      let(:attribute) { :email }
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

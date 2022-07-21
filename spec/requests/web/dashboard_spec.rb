require 'rails_helper'

RSpec.describe "Web::Dashboards", type: :request do
  describe "GET /show" do
    let(:dispatch_request) { get '/web/dashboard' }

    context 'when there is a current user' do
      include_context 'current user'

      it "returns http success" do
        dispatch_request

        expect(response).to have_http_status(:success)
        expect(response.body).to include('Dashboard actions')
      end
    end

    context 'when there is not a current user' do
      it 'redirects to web root' do
        dispatch_request

        expect(response).to redirect_to(new_web_session_path)
      end
    end
  end
end

require "rails_helper"

RSpec.describe Web::ApplicationController, type: :controller do
  controller do
    def index
      set_user_session(User.last)

      render json: current_user
    end
  end

  let!(:user) { create(:user) }

  describe 'handling user session creating' do
    it 'creates an user session with appropriate parameters' do
      get :index

      expect(session[:current_user_id]).to eq(user.id)
    end

    it 'returns user as current_user' do
      get :index

      expect(response.body).to eq(user.to_json)
    end
  end
end

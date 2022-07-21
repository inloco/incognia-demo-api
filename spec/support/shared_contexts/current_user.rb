RSpec.shared_context 'current user' do
  before do
    allow_any_instance_of(Web::ApplicationController)
      .to receive(:current_user).and_return(current_user)
  end
  let(:current_user) { create(:user) }
end

class Web::DashboardController < Web::ApplicationController
  layout 'signed_in_application'

  before_action :verify_authorization

  def show
  end

  private

  def verify_authorization
    redirect_to new_web_session_path unless current_user
  end
end

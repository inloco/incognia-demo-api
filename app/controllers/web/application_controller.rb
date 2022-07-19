class Web::ApplicationController < ActionController::Base
  layout 'application'

  protected

  def set_user_session(user)
    session[:current_user_id] = user.id
  end

  def current_user
    return nil unless session[:current_user_id]

    @current_user ||= User.find(session[:current_user_id])
  end
  helper_method :current_user
end

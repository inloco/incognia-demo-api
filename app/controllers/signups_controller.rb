class SignupsController < ApplicationController
  rescue_from Incognia::APIError, with: :handle_api_errors

  def show
    assessment = incognia_api.get_signup_assessment(signup_id: params[:id]).to_h

    signup = assessment.slice(:id)

    render json: signup
  end

  private

  def handle_api_errors(exception)
    return render nothing: true, status: 404 if exception.status == 404

    render nothing: true, status: 500
  end

  def incognia_api
    @incognia_api ||= Incognia::Api.new(
      client_id: ENV['INCOGNIA_CLIENT_ID'], client_secret: ENV['INCOGNIA_SECRET']
    )
  end
end

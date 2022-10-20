class ApplicationController < ActionController::API
  INCOGNIA_INSTALLATION_ID_HEADER = 'Incognia-Installation-ID'.freeze

  rescue_from Incognia::APIAuthenticationError,
    with: :handle_api_authentication_errors
  rescue_from Incognia::APIError, with: :handle_api_errors

  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  private

  def handle_api_authentication_errors(exception)
    Rails.logger.error exception.full_message

    render nothing: true, status: 500
  end

  def handle_api_errors(exception)
    Rails.logger.error exception.message

    case exception.status
    when 404
      render nothing: true, status: 404
    when 400
      render json: exception.errors, status: 422
    else
      render nothing: true, status: 500
    end
  end

  def handle_not_found
    render nothing: true, status: 404
  end
end

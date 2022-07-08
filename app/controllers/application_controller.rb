class ApplicationController < ActionController::API
  INCOGNIA_INSTALLATION_ID_HEADER = 'Incognia-Installation-ID'.freeze

  rescue_from Incognia::APIError, with: :handle_api_errors

  private

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
end

class SignupsController < ApplicationController
  INCOGNIA_INSTALLATION_ID_HEADER = 'Incognia-Installation-ID'.freeze
  EN_US_LOCALE = 'en-US'.freeze

  rescue_from Incognia::APIError, with: :handle_api_errors

  def create
    installation_id = request.headers[INCOGNIA_INSTALLATION_ID_HEADER]
    address = params
      .fetch(:structured_address, {})
      .permit(
        :country_name,
        :country_code,
        :state,
        :city,
        :borough,
        :street,
        :number,
        :postal_code
    ).to_h.deep_symbolize_keys

    signup_attrs = { installation_id: installation_id }
    if address.present?
      address.merge!(locale: EN_US_LOCALE) # For simplicity sake

      signup_attrs.merge!(
        address: Incognia::Address::Structured.new(**address)
      )
    end

    assessment = incognia_api.register_signup(**signup_attrs).to_h

    signup = assessment.slice(:id)

    render json: signup
  end

  def show
    assessment = incognia_api.get_signup_assessment(signup_id: params[:id]).to_h

    signup = assessment.slice(:id)

    render json: signup
  end

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

  def incognia_api
    @incognia_api ||= Incognia::Api.new(
      client_id: ENV['INCOGNIA_CLIENT_ID'], client_secret: ENV['INCOGNIA_SECRET']
    )
  end
end

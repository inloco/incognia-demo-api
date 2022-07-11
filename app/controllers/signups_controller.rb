class SignupsController < ApplicationController
  INCOGNIA_INSTALLATION_ID_HEADER = 'Incognia-Installation-ID'.freeze

  rescue_from Incognia::APIError, with: :handle_api_errors

  def create
    signup_params = params.permit(
      :account_id, :email,
      structured_address: [
        :country_name,
        :country_code,
        :state,
        :city,
        :borough,
        :street,
        :number,
        :postal_code
      ]
    ).to_hash.delete_if { |k, v| v.empty? }

    signup_params
      .merge!(installation_id: request.headers[INCOGNIA_INSTALLATION_ID_HEADER])
      .deep_symbolize_keys!

    form = Signups::CreateForm.new(signup_params)
    signup = form.submit

    if signup
      render json: { id: signup.incognia_signup_id }
    else
      render json: { errors: form.errors.to_hash }, status: 422
    end
  end

  def show
    signup = Signups::GetReassessment.call(incognia_signup_id: params[:id])

    render json: { id: signup.incognia_signup_id }
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
end

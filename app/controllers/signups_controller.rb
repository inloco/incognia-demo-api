class SignupsController < ApplicationController
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
    user = form.submit

    if user
      render json: SignupSerializer.new(user:).to_json
    else
      render json: { errors: form.errors.to_hash }, status: 422
    end
  end

  def show
    user = Signups::GetReassessment.call(incognia_signup_id: params[:id])

    render json: SignupSerializer.new(user:).to_json
  end
end

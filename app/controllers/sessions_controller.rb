class SessionsController < ApplicationController
  def create
    account_id = params.fetch(:account_id)

    user = User.find_by!(account_id:)

    form = Signin::PasswordlessForm.new(
      user: user,
      installation_id: request.headers[INCOGNIA_INSTALLATION_ID_HEADER],
    )
    user = form.submit

    if user
      render json: SessionSerializer.new(user:).to_json
    elsif form.errors.any?
      render json: { errors: form.errors.to_hash }, status: :unprocessable_entity
    else
      render json: { otp_required: true }, status: :unauthorized
    end
  end
end

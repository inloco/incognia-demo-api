class SessionsController < ApplicationController
  def create
    account_id = params.fetch(:account_id)

    user = User.find_by!(account_id:)

    form = Signin::PasswordlessForm.new(
      user:,
      installation_id: request.headers[INCOGNIA_INSTALLATION_ID_HEADER],
    )
    logged_in_user = form.submit

    if logged_in_user
      render json: SessionSerializer.new(user: logged_in_user)
    elsif form.errors.any?
      render json: { errors: form.errors.to_hash }, status: :unprocessable_entity
    else
      render json: { otp_required: true }, status: :unauthorized
    end
  end

  def validate_otp
    signin_params = params
      .permit(:account_id, :code)
      .to_hash
      .symbolize_keys

    user = User.find_by!(account_id: signin_params.fetch(:account_id))

    form = Signin::OtpForm.new(user:, code: signin_params.fetch(:code))
    logged_in_user = form.submit

    if logged_in_user
      render json: SessionSerializer.new(user: logged_in_user)
    elsif form.errors.any?
      render json: { errors: form.errors.to_hash }, status: :unprocessable_entity
    else
      render nothing: true, status: :unauthorized
    end
  end
end

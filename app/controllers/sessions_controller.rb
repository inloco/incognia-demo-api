class SessionsController < ApplicationController
  def create
    account_id = params.fetch(:account_id)

    user = User.find_by(account_id:)
    return render nothing: true, status: :unauthorized unless user

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
    account_id, code = params
      .permit(:account_id, :code)
      .values_at(:account_id, :code)

    user = User.find_by!(account_id:)

    form = Signin::OtpForm.new(user:, code:)
    logged_in_user = form.submit

    if logged_in_user
      render json: SessionSerializer.new(user: logged_in_user)
    elsif form.errors.any?
      render json: { errors: form.errors.to_hash }, status: :unprocessable_entity
    else
      render nothing: true, status: :unauthorized
    end
  end

  def validate_qrcode
    account_id, code = params
      .permit(:account_id, :code)
      .values_at(:account_id, :code)

    user = User.find_by!(account_id:)
    form = Signin::ValidateMobileTokenForm.new(user:, code:)
    web_otp_code = form.submit

    if web_otp_code
      SigninChannel.broadcast_to(
        form.signin_code, {
          url: validate_otp_web_session_url,
          email: user.email,
          code: web_otp_code
        }
      )

      render nothing: true, status: :ok
    elsif form.errors.any?
      render json: { errors: form.errors.to_hash }, status: :unprocessable_entity
    else
      render nothing: true, status: :unauthorized
    end
  end
end

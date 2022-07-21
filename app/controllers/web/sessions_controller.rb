class Web::SessionsController < Web::ApplicationController
  skip_before_action :verify_authenticity_token, only: :validate_otp
  before_action :redirect_if_logged_in, except: :destroy

  def new
    @form = Signin::MobileTokenForm.new
  end

  def create
    email = params.require(:signin_mobile_token_form).fetch(:email)

    @form = Signin::MobileTokenForm.new(email:)
    @code = @form.submit

    respond_to do |format|
      if @code
        @qrcode = RQRCode::QRCode.new(@code).as_svg(
          color: "000",
          use_path: true,
          viewbox: true
        )

        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    reset_session

    redirect_to web_root_path
  end

  def validate_otp
    email, code = params.permit(:email, :code).values_at(:email, :code)

    user = User.find_by!(email:)

    form = Signin::OtpForm.new(user:, code:)
    logged_in_user = form.submit

    if logged_in_user
      set_user_session(logged_in_user)

      head :ok
    elsif form.errors.any?
      render json: { errors: form.errors.to_hash }, status: :unprocessable_entity
    else
      head :unauthorized
    end
  end

  private

  def redirect_if_logged_in
    redirect_to web_root_path if current_user
  end
end

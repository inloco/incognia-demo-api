class Web::SessionsController < Web::ApplicationController
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
end

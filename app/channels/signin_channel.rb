class SigninChannel < ApplicationCable::Channel
  def subscribed
    signin_code = SigninCode.find_by(code: params[:code])
    reject unless signin_code

    stream_for signin_code
  end
end

require 'forwardable'

class IncogniaApi
  include Singleton

  extend Forwardable
  def_delegators :incognia_api, :register_signup, :get_signup_assessment,
    :register_login

  private

  def incognia_api
    @incognia_api ||= Incognia::Api.new(
      client_id: ENV['INCOGNIA_CLIENT_ID'],
      client_secret: ENV['INCOGNIA_SECRET']
    )
  end
end

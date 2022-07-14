require 'forwardable'

module IncogniaApi
  class Adapter
    extend Forwardable
    def_delegators :api,
      :register_signup, :get_signup_assessment, :register_login

    private

    def api
      Connection.instance.api
    end
  end
end

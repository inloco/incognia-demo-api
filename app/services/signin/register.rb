module Signin
  class Register
    class << self
      def call(user:, installation_id:)
        IncogniaApi::Adapter.new.register_login(
          account_id: user.account_id,
          installation_id:,
        )
      end
    end
  end
end

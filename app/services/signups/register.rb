module Signups
  class Register
    class << self
      def call(installation_id:, structured_address: nil)
        attrs = { installation_id: }

        if structured_address
          attrs.merge!(
            address: Incognia::Address::Structured.new(**structured_address)
          )
        end

        IncogniaApi::Adapter.new.register_signup(**attrs)
      end
    end
  end
end

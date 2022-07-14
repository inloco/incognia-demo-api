module IncogniaApi
  class Connection
    include Singleton

    def api
      @api ||= Incognia::Api.new(
        client_id: ENV['INCOGNIA_CLIENT_ID'],
        client_secret: ENV['INCOGNIA_SECRET']
      )
    end
  end
end

module Alf
  module Rack
    module Helpers

      # Returns Alf configuration previously installed by the Connect
      # middleware
      def alf_config
        env[Alf::Rack::Connect::CONFIG_KEY]
      end

      # Returns Alf's connection previously installed by the Connect
      # middleware
      def alf_connection
        alf_config.connection
      end

      # Executes a query on the connection and returns the result.
      def query(*args, &bl)
        alf_connection.query(*args, &bl)
      end

      # Requests a relvar on the connection and returns it.
      def relvar(*args, &bl)
        alf_connection.relvar(*args, &bl)
      end

      # Requests a tuple on the connection and returns it.
      def tuple_extract(*args, &bl)
        alf_connection.tuple_extract(*args, &bl)
      end

    end # module Helpers
  end # module Rack
end # module Alf

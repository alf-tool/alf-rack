module Alf
  module Rack
    class Config < Support::Config

      # The database instance to use for obtaining connections
      option :database, Database, nil

      # The connection options to use
      option :connection_options, Hash, {}

      # Enclose all requests in a single database transaction?
      option :transactional, Boolean, false

      # Sets the database, coercing it if required
      def database=(db)
        @database = db.is_a?(Database) ? db : Alf.database(db)
      end

      # Returns the default viewpoint to use
      def viewpoint
        connection_options[:viewpoint]
      end

      # Sets the default viewpoint on connection options
      def viewpoint=(vp)
        connection_options[:viewpoint] = vp
      end

    ### At runtime (requires having dup the config first)

      # The current database connection
      attr_reader :connection

      # Connects to the database, starts a transaction if required, then
      # yields the block with the connection object.
      #
      # The connection is kept under an instance variable and can be later
      # obtained through the `connection` accessor. Do NOT use this method
      # without having called `dup` on the config object as it relies on
      # shared mutable state.
      def connect(&bl)
        return yield unless database
        database.connect(connection_options) do |conn|
          @connection = conn
          if transactional?
            conn.in_transaction{ yield(conn) }
          else
            yield(conn)
          end
        end
      end

      # Reconnect with new options. This method is provided if you want to
      # use another viewpoint than the original one in the middle of the
      # request treatment.
      def reconnect(opts)
        connection.reconnect(opts)
      end

    end # class Config
  end # module Rack
end # module Alf

module Alf
  module Rack
    # Connect to a database and make the connection available in the Rack
    # environment.
    #
    # Example:
    #
    # ```
    # require 'sinatra'
    #
    # use Alf::Rack::Connect do |cfg|  # see Alf::Rack::Config
    #   cfg.database = ... # (required) a Alf::Database or Alf::Adapter
    # end
    #
    # get '/' do
    #   # the configuration object (a dup of what has been seen above)
    #   config = env[Alf::Rack::Connect::CONFIG_KEY]
    #
    #   # the config object is connected
    #   connection = config.connection
    #   # => Alf::Database::Connection
    #
    #   # ...
    # end
    # ```
    class Connect

      CONFIG_KEY = "ALF_RACK_CONFIG".freeze

      def initialize(app, config = Config.new)
        @app    = app
        @config = config
        yield(config) if block_given?
      end

      def call(env)
        env[CONFIG_KEY] = cfg = @config.dup
        cfg.connect do
          @app.call(env)
        end
      end

    end # class Connect
  end # module Rack
end # module Alf

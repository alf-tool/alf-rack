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
    #   conn = env[Alf::Rack::Connect::KEY]
    #   # => Alf::Database::Connection
    #
    #   # do as usual
    #   conn.query{ ... }
    #
    #   # ...
    # end
    # ```
    class Connect

      KEY = "ALF_RACK_CONNECTION".freeze

      def initialize(app, config = Config.new)
        @app    = app
        @config = config
        yield(config) if block_given?
      end

      def call(env)
        env[KEY] = cfg = @config.dup
        cfg.connect do
          @app.call(env)
        end
      end

    end # class Connect
  end # module Rack
end # module Alf

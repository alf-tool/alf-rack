require "ruby_cop"
module Alf
  module Rack
    # This Rack application allows client to query your database by simply
    # sending Alf queries as body of POST requests. It automatically run those
    # queries on the current connection and encodes the result according to
    # the HTTP_ACCEPT header.
    #
    # IMPORTANT: Alf has no true parser for now. In order to mitigate the risk
    # of exposing serious attack vectors, you MUST take care of installing the
    # safer parser on your database, as illustrated below. This seriously makes
    # attacks harder, unfortunately without any guarantee...
    #
    # By default, this class catches all errors (e.g. syntax, type-checking
    # security, runtime query execution) and return a 400 response with the
    # error message. A side-effect is that all tuples are loaded in memory
    # before returning the response, to ensure that any error is discovered
    # immediately. When setting `catch_all` to false, this class sets a relvar
    # instance as response body and let all errors percolate up the Rack stack.
    # This means that errors may occur later, during actual query execution.
    #
    # Example:
    #
    # ```
    # # in a config.ru or something
    #
    # # Create a database with a safer parser than usual
    # require 'alf/lang/parser/safer'
    # DB = Alf::Database.new(...){|opts|
    #   opts.parser = Alf::Lang::Parser::Safer
    # }
    #
    # Connect the database on every request
    # use Alf::Rack::Connect{|cfg|
    #   cfg.database = DB
    # } 
    #
    # # let the query engine run under '/'
    # run Alf::Rack::Query.new{|q|
    #   q.type_check = false  # to bypass expressions type-checking
    #   q.catch_all  = false  # to let errors percolate
    # }
    # ```
    class Query
      include Alf::Rack::Helpers

      # Rack response when not found
      NOT_FOUND = [404, {}, []]

      # Recognized URLs
      RECOGNIZED_URLS_RX = /^(\/(data|metadata|logical|physical)?)?$/

      # Apply type checking (defaults to true)? 
      attr_accessor :type_check
      alias         :type_check? :type_check

      # Catch all errors or let them percolate up the stack (default to true)?
      attr_accessor :catch_all
      alias         :catch_all? :catch_all

      # Creates an application instance
      def initialize
        @type_check = true
        @catch_all  = true
        yield(self) if block_given?
      end

      # Call on a duplicated instance
      def call(env)
        return NOT_FOUND unless env['REQUEST_METHOD'] == 'POST'
        return NOT_FOUND unless env['PATH_INFO'] =~ RECOGNIZED_URLS_RX
        dup._call(env)
      end

      # Set the environment, execute the query and encode the response.
      def _call(env)
        @env = env
        Alf::Rack::Response.new(env){|r|
          safe(r){ execute }
        }.finish
      end
      attr_reader :env

    private

      # Executes the block in a begin/rescue implementing the catch_all
      # strategy
      def safe(response)
        result = yield
        result.to_a if catch_all?
        response.body = result
      rescue => ex
        raise unless catch_all?
        response.status = 400
        response.body = {"error" => "#{ex.class}: #{ex.message}" }
      end

      # Executes the request
      def execute
        case env['PATH_INFO']
        when '', '/', '/data' then data
        when '/metadata'      then metadata
        when '/logical'       then logical_plan
        when '/physical'      then physical_plan
        end
      end

      def data
        relvar(query)
      end

      def metadata
        keys    = query.keys.to_a.map{|k| k.to_a }
        heading = Relation(query.heading.to_hash.each_pair.map{|k,v|
          {attribute: k, type: v.to_s}
        })
        {heading: heading, keys: keys}
      end

      def logical_plan
        {
          origin:    query.to_ascii_tree,
          optimized: relvar(query).expr.to_ascii_tree
        }
      end

      def physical_plan
        {
          plan: relvar(query).to_cog.to_ascii_tree
        }
      end

      # Parse and type check the query from body input. Keep it under @query.
      def query
        @query ||= begin
          query = env['rack.input'].read
          query = alf_connection.parse(query)
          query.type_check if type_check?
          query
        end
      end

    end # class Query
  end # module Rack
end # module Alf

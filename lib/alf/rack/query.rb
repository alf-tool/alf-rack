require "ruby_cop"
module Alf
  module Rack
    # This Rack application allows client to query your database by simply
    # sending Alf queries as body of POST requests. It automatically run those
    # queries on the current connection and encodes the result according to
    # the HTTP_ACCEPT header.
    #
    # IMPORTANT: until Alf gains a true parser for algebra expressions, you
    # should avoid using this class in unsafe environments. Indeed, only
    # queries in the Ruby DSL are supported for now, and the ruby engine is
    # used to parse them, which must be considered dangerous. We use RubyCop
    # to mitigate the risks but cannot ensure that all attack vectors are
    # removed.
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
    # # connect as usual
    # use Alf::Rack::Connect{|cfg|
    #   cfg.database = ...
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
        return NOT_FOUND unless env['PATH_INFO'] =~ /^\/(metadata)?$/
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
        when '/'         then get_relvar
        when '/metadata' then metadata(get_relvar)
        end
      end

      def metadata(relvar)
        keys = relvar.keys.to_a.map{|k| k.to_a }
        heading = relvar.heading.to_hash.each_pair.map{|k,v|
          {attribute: k, type: v.to_s}
        }
        {heading: Relation(heading), keys: keys}
      end

      # Execute the request and returns the corresponding relvar
      def get_relvar
        query = env['rack.input'].read
        query = check_safety(query)
        query = parse_query(query)
        query.type_check if type_check?
        relvar(query)
      end

      # Checks that `query` is sufficiently safe ruby code
      def check_safety(query)
        policy = RubyCop::Policy.new
        ast    = RubyCop::NodeBuilder.build(query)
        raise QueryError, "Invalid query '#{query}'" unless ast.accept(policy)
        query
      rescue SyntaxError => ex
        raise QueryError, ex.message
      end

      # Parse the query using Alf and returns the expression tree
      def parse_query(query)
        alf_connection.parse(query)
      end

    end # class Query
  end # module Rack
end # module Alf

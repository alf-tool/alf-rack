module Alf
  module Rack
    # Specialization of `::Rack::Response` that automatically handles the
    # encoding of tuples and relations according to HTTP_ACCEPT and available
    # renderers.
    #
    # Example:
    #
    # ```
    # require 'sinatra'
    #
    # use Alf::Rack::Connect{|cfg| ... }
    # 
    # get '/users' do
    #   # get the connection (see Alf::Rack::Connect)
    #   conn = ...
    #
    #   # The body relation/relvar will automatically be encoded to
    #   # whatever format the user want among the available ones.
    #   # The Content-Type response header is set accordingly.
    #   Alf::Rack::Response.new(env){|r|
    #     r.body = conn.query{ users }
    #   }.finish
    # end
    # ```
    #
    class Response < ::Rack::Response

      # Prepares a Response instance for a given Rack environment. Raises an
      # AcceptError if no renderer can be found for the `HTTP_ACCEPT` header.
      def initialize(env = {})
        @renderer = Response.renderer!(env)
        super([], 200, 'Content-Type' => @renderer.mime_type)
      end

      # Sets the body of the response to `payload`. The latter can be any
      # object that Alf is able to render through the IO renderers (relations,
      # relvars, tuples, etc.).
      def body=(payload)
        super(@renderer.new(payload))
      end

      class << self

        # Returns the best renderer to use given HTTP_ACCEPT header and
        # available Alf renderers.
        def renderer(env)
          media_type = ::Rack::Accept::MediaType.new(accept(env))
          if best = media_type.best_of(supported_media_types)
            Renderer.each.find{|(name,_,r)| r.mime_type == best }.last
          end
        end

        # Returns the renderer to use for `env`. Raises an AcceptError if no
        # renderer can be found.
        def renderer!(env)
          renderer(env) || raise(AcceptError, "Unsupported content type `#{accept(env)}`")
        end

        # Returns the HTTP_ACCEPT header of `env`. Defaults to 'application/json'
        def accept(env)
          env['HTTP_ACCEPT'] || 'application/json'
        end

        # Returns media types supported by the Renderer class.
        def supported_media_types
          Renderer.each.map{|(_,_,r)| r.mime_type}.compact.sort
        end

      end # class << self

    end # class Response
  end # module Rack
end # module Alf

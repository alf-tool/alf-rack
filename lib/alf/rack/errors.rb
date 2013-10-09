module Alf
  module Rack

    # Superclass of all Alf::Rack errors
    class Error < StandardError; end

    # Raised when Alf is unable to convert a tuple or relation into the
    # requested mime type (HTTP_ACCEPT).
    class AcceptError < Error; end

    # Raised by the Query middleware when a query seems invalid.
    class QueryError < StandardError; end

  end # module Rack
end # module Alf

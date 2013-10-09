module Alf
  module Rack

    # Raised when Alf is unable to convert a tuple or relation into the 
    # requested mime type (HTTP_ACCEPT)
    class AcceptError < StandardError; end

  end # module Rack
end # module Alf

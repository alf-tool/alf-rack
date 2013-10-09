require 'spec_helper'
module Alf
  module Rack
    describe Response, '.supported_media_types' do

      subject{ Response.supported_media_types }

      it{ should be_a(Array) }

      it{ should_not be_empty }

      it{ should include("text/plain") }
      it{ should include("text/csv") }
      it{ should include("application/json") }

    end
  end
end

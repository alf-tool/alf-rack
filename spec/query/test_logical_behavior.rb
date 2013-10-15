require 'spec_helper'
require 'alf/rack/query'
module Alf
  module Rack
    describe Query, 'POST /logical' do
      include ::Rack::Test::Methods

      def mock_app(&bl)
        sap = self.sap
        ::Rack::Builder.new do
          use Alf::Rack::Connect do |cfg|
            cfg.database = sap
          end
          run Alf::Rack::Query.new
        end
      end

      let(:app){ mock_app }

      subject{ post("/logical", body, {"HTTP_ACCEPT" => "text/plain"}) }

      before{ subject }

      context 'when the body contains a valid query' do
        let(:body){
          "suppliers"
        }

        it 'succeeds' do
          last_response.status.should eq(200)
        end

        it 'returns the expected plans' do
          last_response.body.should =~ /origin/
          last_response.body.should =~ /optimized/
          last_response.body.should =~ /suppliers/
        end
      end
    end
  end
end

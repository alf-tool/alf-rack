require 'spec_helper'
require 'alf/rack/query'
module Alf
  module Rack
    describe Query, 'POST /metadata' do
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

      subject{ post("/metadata", body, {}) }

      before{ subject }

      context 'when the body contains a valid query' do
        let(:body){
          "suppliers"
        }

        it 'succeeds' do
          last_response.status.should eq(200)
        end

        it 'correctly sets the content type' do
          last_response.content_type.should eq('application/json')
        end
        
        it 'returns the expected answer' do
          body = ::JSON.parse(last_response.body)
          body["heading"].should be_a(Array)
          body["keys"].should be_a(Array)
        end
      end
    end
  end
end

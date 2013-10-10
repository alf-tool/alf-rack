require 'spec_helper'
require 'alf/rack/query'
module Alf
  module Rack
    describe Query, 'POST /' do
      include ::Rack::Test::Methods

      def mock_app(&bl)
        ::Rack::Builder.new do
          use Alf::Rack::Connect do |cfg|
            cfg.database = Alf::Test::Sap.adapter(:sqlite)
          end
          run Alf::Rack::Query.new
        end
      end

      let(:app){ mock_app }

      subject{ post(url, body, {}) }

      before{ subject }

      let(:url){ '/' }

      context 'when the body contains a valid query' do
        let(:body){
          "restrict(suppliers, city: 'London')"
        }

        it 'succeeds' do
          last_response.status.should eq(200)
        end

        it 'correctly sets the content type' do
          last_response.content_type.should eq('application/json')
        end

        it 'returns the expected suppliers' do
          body = ::JSON.parse(last_response.body)
          body.should be_a(Array)
          body.size.should eq(2)
          body.map{|t| t["city"]}.uniq.should eq(["London"])
          body.map{|t| t["sid"]}.should eq(["S1", "S4"])
        end
      end

      context 'when the url is empty' do
        let(:url){ '' }
        let(:body){
          "restrict(suppliers, city: 'London')"
        }

        it 'succeeds' do
          last_response.status.should eq(200)
        end
      end

      shared_examples_for 'an invalid client request' do
        it 'leads to a 400 status' do
          last_response.status.should eq(400)
        end

        it 'has the correct resuting content type' do
          last_response.content_type.should eq('application/json')
        end

        it 'leads to an error message' do
          body = ::JSON.parse(last_response.body)
          body.should be_a(Hash)
          body.keys.should eq(["error"])
          body["error"].should =~ expected_message
        end
      end

      context 'when the body contains a syntax error' do
        let(:body){
          "restrict(suppliers, city: 'Lond)"
        }
        let(:expected_message){
          /syntax error/
        }

        it_should_behave_like "an invalid client request"
      end

      context 'when the body contains a semantic error' do
        let(:body){
          "restrict(supplrs, city: 'London')"
        }
        let(:expected_message){
          /No such relvar `supplrs`/
        }

        it_should_behave_like "an invalid client request"
      end

      context 'when the body contains an attack attempt' do
        let(:body){
          "`ls -lA`"
        }
        let(:expected_message){
          /Invalid query '`ls -lA`'/
        }

        it_should_behave_like "an invalid client request"
      end

      context 'when not a POST request' do
        subject{ get("/") }

        it 'fails with a 404' do
          last_response.status.should eq(404)
        end
      end

    end
  end
end

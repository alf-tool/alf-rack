require_relative '0-commons'
require 'alf/rack/query'   # not required by default

# This examples illustrates the use of Alf::Rack::Query that allows responding
# to end-user queries in a simple way.
#
# IMPORTANT: Alf::Rack::Query MUST be considered unsafe, as it currently
# relies on passing ruby code from the client to the server.
# We use Parser::Safer to mitigate the risks, but until Alf has a true parser
# for relational expressions, this scheme should probably not be used in
# unsafe environments.
QueryApp = ::Rack::Builder.new do

  # See 1-basic.rb
  require 'alf/lang/parser/safer'
  use Alf::Rack::Connect do |cfg|
    adapter = Alf::Test::Sap.adapter(:sqlite)
    cfg.database = Alf::Database.new(adapter){|opt|
      opt.parser = Alf::Lang::Parser::Safer
    }
  end

  # This is the application. It reponds to POST requests and accept queries
  # on the request body. Only `application/ruby` content types are supported
  # for now.
  #
  # The query result is automatically encoded according to HTTP_ACCEPT using
  # the Alf::Rack::Response class.
  run Alf::Rack::Query.new
end

### Test time! ###############################################################

describe QueryApp do
  include Rack::Test::Methods

  def app
    QueryApp
  end

  subject{ post("/", body, env) }

  let(:env){
    {
      "HTTP_CONTENT_TYPE" => "application/ruby",
      "HTTP_ACCEPT"       => "application/json"
    }
  }

  before{ subject }

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

  ## see the spec folder for other tests on Query
end

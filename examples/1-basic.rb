require_relative '0-commons'
require 'sinatra/base'

# This example illustrates a basic usage of Alf::Rack for serving content
# with Alf in a web application context.
class BasicApp < Sinatra::Base
  include Alf::Rack::Helpers

  # We explicitely set the supported media types using `Rack::Accept`
  # so as to automate 406 response if content cannot be served as
  # requested.
  #
  # Not setting may lead to Alf::Rack::AcceptError on Response creation
  # time when a HTTP_ACCEPT header cannot be fulfilled. An alternative is
  # of course to rescue that exception.
  use(Rack::Accept) do |context|
    context.media_types = Alf::Rack::Response.supported_media_types
  end

  # Let connect to the suppliers and parts examplar that comes with Alf::Test.
  #
  # This sets a config object on the Rack env object, under
  # Alf::Rack::Connect::CONFIG_KEY. That config object will have an open
  # connection at request time.
  use Alf::Rack::Connect do |cfg|
    cfg.database = Alf::Test::Sap.adapter(:sqlite)
  end

  # Let serve the list of suppliers
  get '/suppliers' do
    # Rack::Response automatically handles the HTTP_ACCEPT header and
    # will encode the body using Alf renderers.
    Alf::Rack::Response.new(env){|r|

      # The `query` method comes from Alf::Rack::Helpers, that simply
      # delegates the call to the connection object.
      #
      # Not that `query` loads the result in memory. We might better make
      # use of `relvar` instead.
      r.body = query{ suppliers }

    }.finish
  end

  # this is for testing purpose below
  enable  :raise_errors
  disable :show_exceptions
end

### Test time! ###############################################################

describe BasicApp do
  include Rack::Test::Methods

  def app
    BasicApp
  end

  subject{ get('/suppliers', {}, env) }

  before{ subject }

  describe "GET /suppliers (the base case)" do
    let(:env){ Hash.new }

    it 'succeeds' do
      last_response.status.should eq(200)
    end

    it 'defaults to application/json' do
      last_response.content_type.should eq("application/json")
    end

    it 'returns valid JSON' do
      body = ::JSON.parse(last_response.body)
      body.should be_a(Array)
      body.size.should eq(5)
    end
  end

  describe "GET /suppliers with a specific HTTP_ACCEPT" do
    let(:env){ {"HTTP_ACCEPT" => "text/*"} }

    it 'succeeds' do
      last_response.status.should eq(200)
    end

    it 'defaults to text/csv' do
      last_response.content_type.should eq("text/csv")
    end

    it 'returns expected CSV' do
      last_response.body.should =~ /sid,name,status,city/
    end
  end

  describe "GET /suppliers with an unsupported format" do
    let(:env){ {"HTTP_ACCEPT" => "text/unknown"} }

    it 'has an Unacceptable status' do
      last_response.status.should eq(406)
    end
  end

end

require 'spec_helper'
module Alf
  module Rack
    describe Response, 'initialize' do

      subject{ Response.new({"HTTP_ACCEPT" => accept}) }

      context 'when supported' do
        let(:accept){ "application/json" }

        it{ should be_a(Response) }

        it 'sets the Content-Type header immediately' do
          subject['Content-Type'].should eq(accept)
        end
      end

      context 'when not supported' do
        let(:accept){ "text/unknown" }

        it 'raises an AcceptError' do
          lambda{
            subject
          }.should raise_error(AcceptError, /Unsupported(.*?)`text\/unknown`/)
        end
      end

    end
  end
end

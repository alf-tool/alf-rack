require 'spec_helper'
module Alf
  module Rack
    describe Response, '.renderer!' do

      subject{ Response.renderer!({"HTTP_ACCEPT" => accept}) }

      context 'on supported' do
        let(:accept){ "application/json" }

        it{ should be(Renderer::JSON) }
      end

      context 'on unsupported' do
        let(:accept){ "text/unknown" }

        it 'raises a AcceptError' do
          lambda{
            subject
          }.should raise_error(AcceptError, /Unsupported content type `text\/unknown`/)
        end
      end

    end
  end
end

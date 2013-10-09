require 'spec_helper'
module Alf
  module Rack
    describe Response, '.renderer' do

      subject{ Response.renderer({"HTTP_ACCEPT" => accept}) }

      context 'application/json' do
        let(:accept){ "application/json" }

        it{ should be(Renderer::JSON) }
      end

      context 'text/plain' do
        let(:accept){ "text/plain" }

        it{ should be(Renderer::Text) }
      end

      context 'text/csv' do
        let(:accept){ "text/csv" }

        it{ should be(Renderer::CSV) }
      end

      context 'text/x-yaml' do
        let(:accept){ "text/x-yaml" }

        it{ should be(Renderer::YAML) }
      end

      context '*/*' do
        let(:accept){ "*/*" }

        it{ should be(Renderer::JSON) }
      end

      context 'text/unknown' do
        let(:accept){ "text/unknown" }

        it{ should be(nil) }
      end

      context 'a complex one' do
        let(:accept){ "text/unknown, text/*;q=0.8, */*;q=0.5" }

        it{ should be(Renderer::CSV) }
      end

    end
  end
end

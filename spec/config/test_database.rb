require 'spec_helper'
module Alf
  module Rack
    describe Config, "database=" do

      let(:config){ Config.new }

      subject{ 
        config.database = db
        config.database
      }

      context 'with a Alf::Database' do
        let(:db){ Alf.database(Path.dir) }

        it{ should be_a(Alf::Database) }
        it{ should be(db) }
      end

      context 'with an adapter' do
        let(:db){ Path.dir }

        it{ should be_a(Alf::Database) }
      end

    end
  end
end

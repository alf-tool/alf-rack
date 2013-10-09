require 'spec_helper'
module Alf
  module Rack
    describe Response, 'the underlying principle' do

      let(:env){
        {"HTTP_ACCEPT" => "text/unknown, text/*;q=0.8, */*;q=0.5"}
      }

      subject{
        Response.new(env){|r| r.body = body }.finish
      }

      shared_examples_for "the expected Response object" do
        it{ should be_a(Array) }

        it 'sets the Content-Type according to found renderer' do
          subject[1]['Content-Type'].should eq("text/csv")
        end
      end

      context 'when the body is a Relation' do
        let(:body){
          Relation(id: [1, 2, 3])
        }

        it 'encodes the body with found renderer' do
          seen = []
          subject.last.each do |x|
            seen << x
          end
          seen.should eq(["id\n","1\n","2\n","3\n"])
        end
      end

      context 'when the body is a Tuple' do
        let(:body){
          Tuple(name: "Alf", version: "0.15.0")
        }

        it 'encodes the body with found renderer' do
          seen = []
          subject.last.each do |x|
            seen << x
          end
          seen.should eq(["name,version\n","Alf,0.15.0\n"])
        end
      end

      context 'when the body is a Hash' do
        let(:body){
          {name: "Alf", version: "0.15.0"}
        }

        it 'encodes the body with found renderer' do
          seen = []
          subject.last.each do |x|
            seen << x
          end
          seen.should eq(["name,version\n","Alf,0.15.0\n"])
        end
      end

    end
  end
end

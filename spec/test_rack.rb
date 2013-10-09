require 'spec_helper'
module Alf
  describe Rack do

    it "should have a version number" do
      Rack.const_defined?(:VERSION).should be_true
    end

  end
end
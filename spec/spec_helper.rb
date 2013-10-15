$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'alf-rack'
require 'alf-sequel'
require "rspec"
require 'rack'
require 'rack/test'
require "sequel"
require 'sinatra'
require 'path'

module Helpers

  def sap
    Alf::Adapter.factor Path.dir/"sap.db"
  end

end

RSpec.configure do |c|
  c.include Helpers
  c.extend  Helpers
end
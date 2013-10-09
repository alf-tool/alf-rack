$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'alf-test'
require 'alf-rack'
require 'alf-sequel'
require "rspec"
require 'rack'
require 'rack/test'
require "sequel"
require 'sinatra'
require 'path'

module Helpers

end

RSpec.configure do |c|
  c.include Helpers
  c.extend  Helpers
  c.filter_run_excluding :ruby19 => (RUBY_VERSION < "1.9")
end
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require "alf/rack/version"
$version = Alf::Rack::Version.to_s

Gem::Specification.new do |s|
  s.name = "alf-rack"
  s.version = $version
  s.summary = "A collection of Rack middlewares for using Alf in web applications"
  s.description = "This gems provides Rack middleware to use the full power of Alf in web\napplications."
  s.homepage = "http://github.com/blambeau/alf"
  s.authors = ["Bernard Lambeau"]
  s.email  = ["blambeau at gmail.com"]
  s.require_paths = ['lib']
  here = File.expand_path(File.dirname(__FILE__))
  s.files = File.readlines(File.join(here, 'Manifest.txt')).
                 inject([]){|files, pattern| files + Dir[File.join(here, pattern.strip)]}.
                 collect{|x| x[(1+here.size)..-1]}
  s.add_development_dependency("path", "~> 1.3")
  s.add_development_dependency("sinatra", "~> 1.4")
  s.add_development_dependency("rack-test", "~> 0.6.2")
  s.add_development_dependency("alf-sequel", "~> 0.15.0")
  s.add_development_dependency("sequel", "~> 4.2")
  s.add_development_dependency("sqlite3", "~> 1.3")
  s.add_development_dependency("rake", "~> 10.1")
  s.add_development_dependency("rspec", "~> 2.14")
  s.add_dependency("rack", "~> 1.5")
  s.add_dependency("rack-accept", "~> 0.4.5")
  s.add_dependency("alf-core", "~> 0.15.0")
  s.add_dependency("ruby_cop", "~> 1.0")
end

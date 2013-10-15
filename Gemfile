source 'http://rubygems.org'

group :runtime do
  gem "rack", "~> 1.5"
  gem "rack-accept", "~> 0.4.5"
  gem "ruby_cop", "~> 1.0"

  gem "alf-core", path: "../alf-core"
end

group :development do
  gem "rack-test", "~> 0.6.2"
  gem "rake", "~> 10.1"
  gem "path", "~> 1.3"
  gem "rspec", "~> 2.14"
  gem "sinatra", "~> 1.4"
  gem "sqlite3", "~> 1.3",      :platforms => ['mri', 'rbx']
  gem "jdbc-sqlite3", "~> 3.7", :platforms => ['jruby']
  gem "sequel", "~> 4.2"

  gem "alf-sql",    path: "../alf-sql"
  gem "alf-sequel", path: "../alf-sequel"
end

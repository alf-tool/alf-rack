# Alf::Rack

[![Build Status](https://secure.travis-ci.org/alf-tool/alf-rack.png)](http://travis-ci.org/alf-tool/alf-rack)
[![Dependency Status](https://gemnasium.com/alf-tool/alf-rack.png)](https://gemnasium.com/alf-tool/alf-rack)
[![Code Climate](https://codeclimate.com/github/alf-tool/alf-sql.png)](https://codeclimate.com/github/alf-tool/alf-rack)

A collection of Rack middlewares for using Alf in web applications.

## Links

* http://github.com/blambeau/alf
* http://github.com/blambeau/alf-rack

## Example: a RESTful-like interface

**See the examples folder for more advanced examples.**

```
require 'sinatra'
require 'alf-rack'

# include some helpers (see later)
include Alf::Rack::Helpers

# This middleware will open a database connection on every request.
# That connection and query methods are available through the helpers.
use Alf::Rack::Connect do |cfg|
  cfg.database = ::Sequel.connect("postgres://...")
end

# Let send all suppliers, automatically use HTTP_ACCEPT to encode in
# requested format (csv, json, etc.)
get '/suppliers' do |id|
  Alf::Rack::Response.new{|r|
    r.body = relvar{ suppliers }
  }.finish
end

# Similar for a single supplier tuple
get '/suppliers/:id' do |id|
  # Find the supplier
  Alf::Rack::Response.new{|r|
    r.body = tuple_extract{ restrict(suppliers, sid: id) }
  }.finish
end
```

## Example: arbitrary queries

```
# As before
use Alf::Rack::Connect do |cfg|
  cfg.database = ::Sequel.connect("postgres://...")
end

# Answers arbitrary queries on POST /
run Alf::Rack::Query.new
```

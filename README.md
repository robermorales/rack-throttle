HTTP Request Rate Limiter for Rack Applications
===============================================
[![Travis CI Status](https://secure.travis-ci.org/Viximo/rack-throttle.png?rvm=1.9.3)](http://travis-ci.org/Viximo/rack-throttle)

This is [Rack][] middleware that provides logic for rate-limiting incoming
HTTP requests to Rack applications. You can use `Rack::Throttle` with any
Ruby web framework based on Rack, including with Ruby on Rails 3.0 and with
Sinatra.

* <http://github.com/datagraph/rack-throttle>

Features
--------

* Throttles a Rack application by enforcing a minimum time interval between
  subsequent HTTP requests from a particular client, as well as by defining
  a maximum number of allowed HTTP requests per a given time period (per minute, 
  hourly, or daily).
* Compatible with any Rack application and any Rack-based framework.
* Stores rate-limiting counters in any key/value store implementation that
  responds to `#[]`/`#[]=` (like Ruby's hashes) or to `#get`/`#set` (like
  memcached or Redis).
* Compatible with the [gdbm][] binding included in Ruby's standard library.
* Compatible with the [memcached][], [memcache-client][], [memcache][] and
  [redis][] gems.
* Compatible with [Heroku][]'s [memcached add-on][Heroku memcache]
  (currently available as a free beta service).
* Compatible with Ruby 1.8.7 & 1.9

Examples
--------

### Adding throttling to a Rails 3.x application

    # config/application.rb
    require 'rack/throttle'
    
    class Application < Rails::Application
      config.middleware.use Rack::Throttle::Interval
    end

### Adding throttling to a Sinatra application

    #!/usr/bin/env ruby -rubygems
    require 'sinatra'
    require 'rack/throttle'
    
    use Rack::Throttle::Interval
    
    get('/hello') { "Hello, world!\n" }

### Adding throttling to a Rackup application

    #!/usr/bin/env rackup
    require 'rack/throttle'
    
    use Rack::Throttle::Interval
    
    run lambda { |env| [200, {'Content-Type' => 'text/plain'}, "Hello, world!\n"] }

### Enforcing a minimum 3-second interval between requests

    use Rack::Throttle::Interval, :min => 3.0

### Allowing a maximum of 60 requests per minute

    use Rack::Throttle::Minute,   :max => 60

### Allowing a maximum of 100 requests per hour

    use Rack::Throttle::Hourly,   :max => 100

### Allowing a maximum of 1,000 requests per day

    use Rack::Throttle::Daily,    :max => 1000

### Combining various throttling constraints into one overall policy

    use Rack::Throttle::Daily,    :max => 1000  # requests
    use Rack::Throttle::Hourly,   :max => 100   # requests
    use Rack::Throttle::Hourly,   :max => 60    # requests
    use Rack::Throttle::Interval, :min => 3.0   # seconds

### Storing the rate-limiting counters in a GDBM database

    require 'gdbm'
    
    use Rack::Throttle::Interval, :cache => GDBM.new('tmp/throttle.db')

### Storing the rate-limiting counters on a Memcached server

    require 'memcached'
    
    use Rack::Throttle::Interval, :cache => Memcached.new, :key_prefix => :throttle

### Storing the rate-limiting counters on a Redis server

    require 'redis'
    
    use Rack::Throttle::Interval, :cache => Redis.new, :key_prefix => :throttle

Throttling Strategies
---------------------

`Rack::Throttle` supports three built-in throttling strategies:

* `Rack::Throttle::Interval`: Throttles the application by enforcing a
  minimum interval (by default, 1 second) between subsequent HTTP requests.
* `Rack::Throttle::Minute`: Throttles the application by defining a
  maximum number of allowed HTTP requests per minute (by default, 60
  requests per minute, which works out to an average of 1 request per
  second).
* `Rack::Throttle::Hourly`: Throttles the application by defining a
  maximum number of allowed HTTP requests per hour (by default, 3,600
  requests per 60 minutes, which works out to an average of 1 request per
  second).
* `Rack::Throttle::Daily`: Throttles the application by defining a
  maximum number of allowed HTTP requests per day (by default, 86,400
  requests per 24 hours, which works out to an average of 1 request per
  second).

You can fully customize the implementation details of any of these strategies
by simply subclassing one of the aforementioned default implementations.
And, of course, should your application-specific requirements be
significantly more complex than what we've provided for, you can also define
entirely new kinds of throttling strategies by subclassing the
`Rack::Throttle::Limiter` base class directly.

HTTP Client Identification
--------------------------

The rate-limiting counters stored and maintained by `Rack::Throttle` are
keyed to unique HTTP clients.

By default, HTTP clients are uniquely identified by their IP address as
returned by `Rack::Request#ip`. If you wish to instead use a more granular,
application-specific identifier such as a session key or a user account
name, you need only subclass a throttling strategy implementation and
override the `#client_identifier` method.

HTTP Response Codes and Headers
-------------------------------
### 429 Too Many Requests
In the past various status codes has been used to indicate over-use.

In 2012, the IETF standardized on a new response status 429 (Too Many Requests)
[RFC6585].

When a client exceeds their rate limit, `Rack::Throttle` by default returns
a 429 (Too Many Requests) header with an associated "Rate Limit Exceeded" message
in the response body.

The status code can be overridden by passing in `:code => 403` option when
constructing a `Rack::Throttle::Limiter` instance.

Documentation
-------------

<http://datagraph.rubyforge.org/rack-throttle/>

* {Rack::Throttle}
  * {Rack::Throttle::Interval}
  * {Rack::Throttle::Daily}
  * {Rack::Throttle::Hourly}

Dependencies
------------

* [Rack](http://rubygems.org/gems/rack) (>= 1.0.0)

Installation
------------

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of the gem, do:

    % [sudo] gem install rack-throttle

Download
--------

To get a local working copy of the development repository, do:

    % git clone git://github.com/datagraph/rack-throttle.git

Alternatively, you can download the latest development version as a tarball
as follows:

    % wget http://github.com/datagraph/rack-throttle/tarball/master

Authors
-------

* [Arto Bendiken](mailto:arto.bendiken@gmail.com) - <http://ar.to/>
* [Brendon Murphy](mailto:disposable.20.xternal@spamourmet.com>) - <http://www.techfreak.net/>

License
-------

`Rack::Throttle` is free and unencumbered public domain software. For more
information, see <http://unlicense.org/> or the accompanying UNLICENSE file.

[Rack]:            http://rack.rubyforge.org/
[gdbm]:            http://ruby-doc.org/stdlib/libdoc/gdbm/rdoc/classes/GDBM.html
[memcached]:       http://rubygems.org/gems/memcached
[memcache-client]: http://rubygems.org/gems/memcache-client
[memcache]:        http://rubygems.org/gems/memcache
[redis]:           http://rubygems.org/gems/redis
[Heroku]:          http://heroku.com/
[Heroku memcache]: http://docs.heroku.com/memcache
[RFC6585]:         http://tools.ietf.org/html/rfc6585

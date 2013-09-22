source 'https://rubygems.org'

gem 'rack'
gem 'rack-throttle'
gem 'sinatra'
gem 'json'
gem 'bson_ext'
gem 'mongo_mapper'
gem 'memcached'

# This is to prevent CloudFoundry from using WEBrick
gem 'thin'

# CloudFoundry is a little dumb in the dependency
# resolution area. Explicit listings here
#gem 'json'
#gem 'httpclient'

group :test do
  gem 'rack-test'
end

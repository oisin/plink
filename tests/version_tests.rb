require 'test/unit'
require 'rack/test'

# Set the ENVs *before* requiring the Sinatra
# app or it will make its own in the configure
# and these will have no effect.
ENV['RACK_ENV'] = 'test'

require '../plink'

class VersionTests < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_compatible_exact
    get '/api/v1.3/track'
    assert_not_equal 400, last_response.status
  end

  def test_compatible_backward
    get '/api/v1.1/track'
    assert_not_equal 400, last_response.status
  end

  def test_incompatible_major
    get '/api/v2.0/track'
    assert_equal 400, last_response.status
  end
  
  def test_incompatible_minor
    get '/api/v1.9/track'
    assert_equal 400, last_response.status
  end

end

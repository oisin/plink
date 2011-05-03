require 'test/unit'
require 'rack/test'

# Set the ENVs *before* requiring the Sinatra
# app or it will make its own in the configure
# and these will have no effect.
ENV['RACK_ENV'] = 'test'

require '../plink'

class RegisterTests < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_register_handset
    payload = { :something => 'mumble' }
    put '/api/v1.3/register', payload.to_json
    assert_equal 200, last_response.status
    assert_not_nil last_response.body, "No identifier returned for handset"
  end

  def test_register_idempotent
    fail
  end
end
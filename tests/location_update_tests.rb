require 'test/unit'
require 'rack/test'

# Set the ENVs *before* requiring the Sinatra
# app or it will make its own in the configure
# and these will have no effect.
ENV['RACK_ENV'] = 'test'

require '../plink'

class LocationUpdateTests < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    PlinkApp
  end

  def setup
    Handset.delete_all
  end
  
  def make_me_a_handset(name)
    payload = { :test => name }
    put '/api/v1.3/register', payload.to_json
    assert_equal 200, last_response.status
    assert_not_nil last_response.body, "No identifier returned for handset"
    last_response.body
  end
  
  def test_update_location
    code = make_me_a_handset('test_update_location')
    location = {
      :handset => code,
      :lat => 53.289193,
      :long => -6.113945
    }
    post '/api/v1.3/plink', location.to_json
    assert_equal 200, last_response.status, "Failed to post location: " + last_response.body
    
    h = Handset.find_by_code(code)
    l = h.locations.last
    assert_not_nil l, "Location not stored correctly"
    assert_equal location[:lat], l[:lat], "Wrong object retrieved"
  end
  
  def test_get_locations
    code = make_me_a_handset('test_get_locations')
    location = {
      :handset => code,
      :lat => 53.289193,
      :long => -6.113945
    }
    
    nposts = 20
    nposts.times do |i|
      post '/api/v1.3/plink', location.to_json
      assert_equal 200, last_response.status, "Failed to post location: " + last_response.body
      location[:lat] += 0.22
    end
    
    h = Handset.find_by_code(code)
    l = h.locations
    assert_equal nposts, h.locations.length, "Not all locations stored"
  end
  
end

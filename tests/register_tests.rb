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

  def make_me_a_handset(name)
    payload = { :test => name }
    put '/api/v1.3/register', payload.to_json
    assert_equal 200, last_response.status
    assert_not_nil last_response.body, "No identifier returned for handset"
    last_response.body
  end
  
  def test_register_handset
    handset = make_me_a_handset('test_register_handset') 
    h = Handset.where(:code => handset).first
    assert_not_nil h, "No handset in database"
  end

  def test_register_idempotent
    handset_1 = make_me_a_handset('test_register_idempotent')
    count = Handset.collection.count
    handset_2 = make_me_a_handset('test_register_idempotent')
    assert_equal count, Handset.collection.count, "Handset registration not idempotent" 
  end
  
  def test_unregister_handset
    handset = make_me_a_handset('test_unregister_handset')
    assert_not_nil Handset.where(:code => handset).first, "No handset in database"
    delete '/api/v1.3/' + handset
    assert_equal 200, last_response.status
    assert_nil Handset.where(:code => handset).first, "Handset not deleted from database"
  end
  
end
require_relative "../app/my_app"
require_relative "../app/myrackmiddleware"
require_relative "../app/algorithm/hs256"
require 'pry'

require "test/unit"
require "rack/test"

class HomepageTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    MyRackMiddleware.new(MyApp.new)
  end

  def test_hmac_key_present_in_env
    hmac_key = "#{ENV["HMAC_KEY"]}"
    assert_equal hmac_key, "my$ecretK3y"
  end
  
  def test_status_401_with_without_token
    get "/"

    assert_equal last_response.status, 401
  end

  def test_status_401_with_not_valid_token
    get "/?token=sdfsdfszg"

    assert_equal last_response.status, 401
  end

  def test_status_200_with_valid_token
    hmac_secret = 'my$ecretK3y'
    payload = { data: 'test' }
    @valid = JWT.encode payload, hmac_secret, 'HS256'

    get "/?token=Bearer #{@valid}"

    assert_equal last_response.status, 200
  end

  def test_status_200_with_valid_token_in_header
    hmac_secret = 'my$ecretK3y'
    payload = { data: 'test' }
    @valid = JWT.encode payload, hmac_secret, 'HS256'

    header 'AUTHORIZATION', "Bearer #{@valid}"
    get "/"

    assert_equal last_response.status, 200
  end

end

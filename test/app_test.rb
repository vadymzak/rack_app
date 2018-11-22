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

  def test_without_token
    get "/"

    assert last_response.status == 401
  end

  def test_not_valid_token
    get "/?token=sdfsdfszg"

    assert last_response.status == 401
  end

  def test_valid_token
    hmac_secret = 'my$ecretK3y'
    payload = { data: 'test' }
    @valid = JWT.encode payload, hmac_secret, 'HS256'

    get "/?token=#{@valid}"

    assert last_response.status == 200
  end

  def test_valid_token_in_header
    hmac_secret = 'my$ecretK3y'
    payload = { data: 'test' }
    @valid = JWT.encode payload, hmac_secret, 'HS256'

    header 'token', @valid
    get "/"

    assert last_response.status == 200
  end

end

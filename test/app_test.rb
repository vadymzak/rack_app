require_relative '../app/my_app'
require_relative '../app/myrackmiddleware'
require 'pry'

require "test/unit"
require "rack/test"

class HomepageTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    MyRackMiddleware.new(MyApp.new)
  end

  def test_response_is_ok
    get '/'
    assert last_response.ok?
    assert_equal last_response.body, 'All responses are OK'
  end

end

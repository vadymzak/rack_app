require 'pry'

class MyRackMiddleware
  attr_reader :request

  def initialize(appl)
    @appl = appl
    @token
  end

  def call(env)
    request(env)
    status, headers, body = @appl.call(env) # we now call the inner application
    get_header
    get_token(@request.GET)
    append_s = check_token
    status = 401 if append_s == "Token not valid"
    [status, headers, body << append_s.to_s]
  end

  def request(env)
    @request = Rack::Request.new(env)
  end

  def get_token(params)
    @token = ""
    params.each { |key, value| @token = value if key == "token"}
  end

  def check_token
    check = Check.new(@token.to_s, get_key)
    unless check.decode_HS256 == false
      return check.decode
    else
      return "Token not valid"
    end
  end

  def get_key
    key = 'my$ecretK3y'
  end

  def get_header
    binding.pry
    request.headers['Authorization']
  end
end

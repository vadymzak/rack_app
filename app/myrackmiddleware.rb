require 'pry'

class MyRackMiddleware
  attr_reader :request

  HMAC_KEY = "#{ENV["HMAC_KEY"]}"

  def initialize(appl)
    @appl = appl
    @token
  end

  def call(env)
    @env = env
    request(env)
    status, headers, body = @appl.call(env) # we now call the inner application
    status = set_status
    @append_s = set_body(status)
    [status, headers, body << @append_s.to_s]
  end

  def request(env)
    @request = Rack::Request.new(env)
  end

  def bearer_token
    @bearer_token = nil
    @bearer_token ||= authorization_header || @request.GET['token']
  end

  def set_body(status)
    if status == 200
      return @check.decode
    else
      return "Token not valid"
    end
  end

  #private

  def check_token?
    bearer_token
    @check = Check.new(@bearer_token.to_s, get_key)
    @check.decode_HS256
  end

  def get_key
    #key = 'my$ecretK3y'
    key = HMAC_KEY
  end

  def authorization_header
    @env['HTTP_TOKEN']
  end

  def check_status?
    check_token?
  end

  def set_status
    check_status?() ? 200 : 401
  end

end

require 'pry'

class MyRackMiddleware
  attr_reader :request

  HMAC_KEY = "#{ENV["HMAC_KEY"]}"

  def initialize(appl)
    @appl = appl
    @token
    @algorithm
    gen_rs256_keys
    p gen_token_rs256
  end

  def call(env)
    @env = env
    request(env)
    status, headers, body = @appl.call(env) # we now call the inner application
    status = set_status
    @append_s = set_body(status)
    [status, headers, body << @append_s.to_s]
  end

  private

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

  def check_token?
    set_algorithm
    @check = Object.const_get("Algorithm::#{@algorithm.capitalize}").new(token, get_key)
    @check.check_decode
  end

  def get_key
    #key = HMAC_KEY
    if @algorithm == 'HS256'
      return key = 'my$ecretK3y'
    elsif @algorithm == 'RS256'
      return key = @rsa_public
    end
  end

  def authorization_header
    @env['HTTP_AUTHORIZATION']
  end

  def check_status?
    check_token?
  end

  def set_status
    check_status?() ? 200 : 401
  end

  def token
    pattern = /^Bearer /
    bearer_token.gsub(pattern, '') if bearer_token&.match(pattern)
  end

  def set_algorithm
    #@algorithm = nil
    @algorithm ||= get_algorithm || 'RS256'
  end

  def get_algorithm
    tm = token.to_s.split('.')
    alg = JSON.parse(Base64.decode64(tm[0].tr('-_', '+/')))['alg']
  end
#--------------------------------------------------------------------------
  def gen_rs256_keys
    @rsa_private = OpenSSL::PKey::RSA.generate 2048
    @rsa_public = @rsa_private.public_key
  end

  def gen_token_rs256
    payload = { login: 'test_user' }
    token = JWT.encode payload, @rsa_private, 'RS256'
  end
end

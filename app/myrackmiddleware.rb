require 'pry'

class MyRackMiddleware
  attr_reader :request

  HMAC_KEY = "#{ENV["HMAC_KEY"]}"

  def initialize(appl)
    @appl = appl
    @token
    @algorithm
    gen_rs256_keys
    gen_token_rs256
  end

  def call(env)
    @env = env
    request(env)
    status, headers, body = @appl.call(env) # we now call the inner application
    status = set_status
    set_response(status)
  end

  private

  def request(env)
    @request = Rack::Request.new(env)
  end

  def bearer_token
    @bearer_token = nil
    @bearer_token ||= authorization_header || @request.GET['token']
  end

  def set_response(status)
    if status == 200
      response_rack(status, get_payload.to_s)
    else
      response_rack(status, "Token not valid")
    end
  end

  def check_token?
    if token == nil
      return false
    end
    @check = Object.const_get("Algorithm::#{set_algorithm.capitalize}").new(token, get_key)
    @check.check_decode
  end

  def get_key
    if @algorithm == 'HS256'
      return key = HMAC_KEY#'my$ecretK3y'
    elsif @algorithm == 'RS256'
      return key = @rsa_public
    end
  end

  def authorization_header
    @env['HTTP_AUTHORIZATION']
  end

  def set_status
    check_token?() ? 200 : 401
  end

  def token
    pattern = /^Bearer /
    bearer_token.gsub(pattern, '') if bearer_token&.match(pattern)
  end

  def set_algorithm
    @algorithm = nil
    @algorithm ||= get_algorithm || 'RS256'
  end

  def get_algorithm
    tm = token.to_s.split('.')
    alg = JSON.parse(Base64.decode64(tm[0].tr('-_', '+/')))['alg']
  end

  def response_rack(status, header)
    resp = Rack::Response.new
    resp.status = status
    resp.set_header("X-Auth-User", header)
    resp.finish
  end

  def get_payload
    tm = token.to_s.split('.')
    payload = JSON.parse(Base64.decode64(tm[1].tr('-_', '+/')))
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

require 'jwt'

class Check
  attr_reader :decode

  def initialize(token, key)
    @token = token
    @hmac_secret = key
    @decode
  end

  def decode_HS256
    begin
      @decode = JWT.decode @token, @hmac_secret, true, { algorithm: 'HS256' }
      true
    rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
      false
    end
  end

end

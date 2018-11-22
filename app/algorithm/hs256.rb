require_relative '../check'
module Algorithm
  class Hs256 < Check

    attr_reader :decode

    def check_decode
      begin
        @decode = JWT.decode @token, @key, true, { algorithm: 'HS256' }
        true
      rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
        false
      end
    end

  end

end

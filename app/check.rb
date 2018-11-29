require 'jwt'

  class Check

    def initialize(token, key)
      @token = token
      @key = key
    end

end

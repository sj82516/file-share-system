class AccessTokenService
  ALGO = 'HS256'

  class DECODE_ERROR < StandardError
  end
  def initialize
    self.hmac_secret = ENV["ACCESS_TOKEN_SECRET"]
  end

  def encode(payload)
    payload[:exp] = 1.day.from_now.to_i
    JWT.encode(payload, hmac_secret, ALGO)
  end

  def decode(token)
    begin
      JWT.decode(token, hmac_secret, true, { algorithm: ALGO }).first
    rescue JWT::DecodeError
      raise DECODE_ERROR
    end
  end

  private

  attr_accessor :hmac_secret
end

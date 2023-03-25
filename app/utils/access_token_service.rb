class AccessTokenService
  ALGO = 'HS256'

  DECODE_ERROR = "Invalid access token.".freeze
  def initialize
    self.hmac_secret = Rails.application.credentials.access_token_secret
  end

  def encode(payload)
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

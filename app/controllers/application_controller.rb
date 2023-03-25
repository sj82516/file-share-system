class ApplicationController < ActionController::API
  # parse access token
  def current_user
    @current_user ||= parse_current_user
  end

  def parse_current_user
    token = request.headers["Authorization"]
    return nil if token.blank?

    begin
      payload = AccessTokenService.new.decode(token)
      return User.find(payload["user_id"])
    rescue AccessTokenService::DECODE_ERROR, ActiveRecord::RecordNotFound
      logger.warn "Invalid access token: #{token}"
    end

    nil
  end

  def authenticate_user!
    render json: { error: "Unauthorized" }, status: 401 unless current_user
  end
end

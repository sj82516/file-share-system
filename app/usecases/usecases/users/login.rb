class Usecases::Users::Login
  class ERROR_USER_NOT_FOUND < StandardError;end
  class ERROR_WRONG_PASSWORD < StandardError;end

  class << self
    def run(email:, password:)
      user = User.find_by(email: email)
      raise ERROR_USER_NOT_FOUND if user.blank?
      raise ERROR_WRONG_PASSWORD unless user.authenticate(password)

      create_access_token(user: user)
    end

    private
    def create_access_token(user:)
      AccessTokenService.new.encode(
        {
          user_id: user.id,
        }
      )
    end
  end

end

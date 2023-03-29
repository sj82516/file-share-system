class Usecases::Users::Register
  class ERROR_EMAIL_DUPLICATE < StandardError;end
  class ERROR_INVALID < StandardError;end

  class << self
    def run(email:, password:)
      begin
        User.create!(
          email: email,
          password: password
        )
      rescue ActiveRecord::RecordNotUnique
        raise ERROR_EMAIL_DUPLICATE
      rescue ActiveRecord::RecordInvalid
        raise ERROR_INVALID
      end
    end
  end
end

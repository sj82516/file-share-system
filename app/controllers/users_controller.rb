class UsersController < ApplicationController

  def register
    begin
      User.create!(
        email: params[:email],
        password: params[:password]
      )
    rescue ActiveRecord::RecordNotUnique
      return render json: { error: "Email already exists" }, status: 409
    rescue ActiveRecord::RecordInvalid
      return render json: { error: "Invalid email or password" }, status: 400
    end

    # password should be encrypted
    render json: {}, status: 201
  end

  def login
    # TODO: add rate limit to prevent brute force attack

    email = params[:email]
    password = params[:password]
    return render json: { error: "Invalid email or password" }, status: 400 if email.blank? || password.blank?

    user = User.find_by(email: email)
    if user && user.authenticate(password)
      render json: { access_token: create_access_token(user: user) }, status: 200
    else
      render json: { error: "Invalid email or password" }, status: 401
    end
  end

  private

  def create_access_token(user:)
    AccessTokenService.new.encode(
      {
        user_id: user.id,
        exp: 24.hours.from_now.to_i
      }
    )
  end
end

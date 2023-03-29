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

    render json: {}, status: 201
  end

  def login
    # TODO: add rate limit to prevent brute force attack

    email = params[:email]
    password = params[:password]
    return render json: { error: "Invalid email or password" }, status: 400 if email.blank? || password.blank?

    begin
      access_token = Usecases::Users::Login.run(email: email, password: password)
      render json: { access_token: access_token }, status: 200
    rescue Usecases::Users::Login::ERROR_USER_NOT_FOUND
      return render json: { error: "User not found" }, status: 401
    rescue Usecases::Users::Login::ERROR_WRONG_PASSWORD
      return render json: { error: "Wrong password" }, status: 401
    end
  end
end

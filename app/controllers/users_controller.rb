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
    email = params[:email]
    password = params[:password]

    user = User.find_by(email: email)
    if user && user.authenticate(password)
      render json: { token: user.token }, status: 200
    else
      render json: { error: "Invalid email or password" }, status: 401
    end
  end
end

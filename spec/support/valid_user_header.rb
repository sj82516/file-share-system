def generate_valid_user_header(user:)
  {
    Authorization: "Bearer #{AccessTokenService.new.encode(user_id: user.id)}",
  }
end

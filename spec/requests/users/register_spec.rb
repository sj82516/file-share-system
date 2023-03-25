require "rails_helper"

describe "POST /users/register", :request do
  let(:email) {}
  let(:password) {}
  let(:user_params) {
    {
      email: email,
      password: password
    }
  }
  let(:do_action) {
    post "/users/register", params: user_params
  }

  context "when user doesn't provide email" do
    it "should return an error" do
      do_action
      expect(response).to have_http_status(:bad_request)
    end
  end

  context "when user provide valid data" do
    let(:email) { "test@mail.com" }
    let(:password) { "123456" }
    it "should create a new user" do
      do_action

      expect(response).to have_http_status(:created)
      expect(User.find_by(email: email)).not_to be_nil
    end
  end

  context "when user email is duplcate" do
    let!(:user) { create(:user, email: email, password: "123") }
    let(:email) { "test@mail.com" }
    let(:password) { "123456" }

    it "should return error" do
      do_action

      expect(response).to have_http_status(:conflict)
    end
  end
end

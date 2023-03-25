require "rails_helper"

describe "POST /users/login", :request do
  let(:email) { "test@mail.com" }
  let(:password) { "123456" }
  let(:user_params) {
    {
      email: email,
      password: password
    }
  }
  let(:do_action) {
    post "/users/login", params: user_params
  }

  context "when user doesn't provide email" do
    let(:email) { nil }
    it "should return an error" do
      do_action
      expect(response).to have_http_status(:bad_request)
    end
  end

  context "when user doesn't provide password" do
    let(:password) { nil }
    it "should return an error" do
      do_action
      expect(response).to have_http_status(:bad_request)
    end
  end

  context "when user email doesn't exist" do
    it "should return error" do
      do_action

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when user provide valid credential" do
    let!(:user) { create(:user, email: email, password: password) }
    it 'should return access token' do
      do_action

      expect(response).to have_http_status(:ok)
    end
  end
end

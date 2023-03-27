require 'rails_helper'

RSpec.describe 'get /files', type: :request do
  let(:user) { create(:user) }
  let(:header) { generate_valid_user_header(user: user) }
  let(:do_action) { get "/files", headers: header }

  context "when user list files" do
    let!(:storage_file) { create(:storage_file, user: user, status: :uploaded) }

    it "should return list of files with private link and share link" do
      expect_any_instance_of(S3StorageProvider).to receive(:signed_cookie_for_private_files).with({ user: user })
      do_action

      expect(response).to have_http_status(200)
      expect(response.body).to include(storage_file.decorate.private_link)
    end

  end

end

require 'rails_helper'

RSpec.describe 'POST /files', type: :request do
  let(:file) { {} }
  let(:header) { {} }
  let(:do_action) { post '/files/upload', params: { file: file }, headers: header }

  context 'user is not logged in' do
    it 'return error' do
      do_action

      expect(response).to have_http_status(401)
    end
  end

  context 'user is logged in' do
    let!(:user) { create(:user) }
    let(:header) {
      {
        Authorization: "Bearer #{AccessTokenService.new.encode(user_id: user.id)}",
      }
    }

    context "when file missing file_name" do
      let(:file) {
        {
          type: 'text/plain',
          size: 10,
        }
      }

      it 'return error' do
        do_action

        expect(response).to have_http_status(400)
      end
    end

    context 'file is valid' do
      let(:file) {
        {
          name: 'test.txt',
          type: 'text/plain',
          size: 10,
        }
      }

      it 'return presigned url' do
        expect_any_instance_of(S3StorageProvider).to receive(:create_upload_presigned_url).with(user, file[:name], file[:type], file[:size]).and_return('presigned_url')
        key = 'key'
        expect(RandomStorageFileKeyGenerator).to receive(:generate).and_return(key)
        do_action

        expect(response).to have_http_status(200)
        expect(response.body['presigned_url']).not_to be_nil
        expect(StorageFile.find_by(key: key, user_id: user.id)).not_to be_nil
      end
    end
  end
end

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
    let(:header) { generate_valid_user_header(user: user) }

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
        key = 'key'
        expect_any_instance_of(S3StorageProvider).to receive(:create_upload_presigned_url).with(user, key,
          file[:type], file[:size]).and_return('presigned_url')
        expect(RandomStorageFileKeyGenerator).to receive(:generate).and_return(key)
        do_action

        expect(response).to have_http_status(200)
        expect(response.body['presigned_url']).not_to be_nil
        expect(StorageFile.find_by(key: key, user_id: user.id)).not_to be_nil
      end
    end

    context "file key collision over 3 times" do
      let(:file) {
        {
          name: 'test.txt',
          type: 'text/plain',
          size: 10,
        }
      }
      let!(:storage_file) { create(:storage_file, user: user) }

      it 'return presigned url' do
        key = 'key'
        allow(RandomStorageFileKeyGenerator).to receive(:generate).and_return(key)

        do_action

        expect(response).to have_http_status(500)
      end
    end

    context 'file key collision first time' do
      let(:file) {
        {
          name: 'test.txt',
          type: 'text/plain',
          size: 10,
        }
      }
      let!(:storage_file) { create(:storage_file, user: user) }

      it 'return presigned url' do
        key = 'key'
        allow(RandomStorageFileKeyGenerator).to receive(:generate).and_return(key).once
        allow(RandomStorageFileKeyGenerator).to receive(:generate).and_return("unique").once

        do_action

        expect(response).to have_http_status(200)
        expect(response.body['presigned_url']).not_to be_nil
        expect(StorageFile.find_by(key: key, user_id: user.id)).not_to be_nil
      end
    end
  end
end

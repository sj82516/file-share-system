require 'rails_helper'
require 'timecop'

RSpec.describe 'post /files/:id/share', type: :request do
  let(:user) { create(:user) }
  let(:header) { generate_valid_user_header(user: user) }
  let(:file_id) { 1 }
  let(:do_action) { post "/files/#{file_id}/share", headers: header }

  context 'when file is not exists' do
    it 'returns 404' do
      do_action

      expect(response).to have_http_status(404)
    end
  end

  context 'when file is exists' do
    let(:storage_file) { create(:storage_file, user: user) }
    let(:file_id) { storage_file.id }

    context "when file is init" do
      it 'returns error' do
        do_action

        expect(response).to have_http_status(400)
      end
    end

    context 'when user is not the owner of file' do
      let(:user2) { create(:user, email: "test@mail.com") }
      let(:storage_file) { create(:storage_file, user: user2, status: :uploaded) }
      let(:user) { create(:user) }

      it 'returns error' do
        do_action

        expect(response).to have_http_status(403)
      end
    end

    context "when file is uploaded" do
      let(:storage_file) { create(:storage_file, user: user, status: :uploaded) }

      it 'returns public url' do
        now = Time.now
        Timecop.freeze(now) do
          expect_any_instance_of(S3StorageProvider).to receive(:public_object).with(storage_file: storage_file).and_return('public_url')
          do_action

          expect(response).to have_http_status(200)
          expect(storage_file.reload.shared_at.to_i).to eq(now.to_i)
          expect(storage_file.reload.shared_expired_at.to_i).to eq((now + Usecases::Files::Share::SHARE_EXPIRE_DURATION)
                                                                 .to_i)
        end
      end
    end
  end
end

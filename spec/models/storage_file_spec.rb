# == Schema Information
#
# Table name: storage_files
#
#  id                :bigint           not null, primary key
#  user_id           :integer          not null
#  status            :integer          default("init"), not null
#  name              :string(255)      not null
#  file_type         :string(255)      not null
#  size              :string(255)      not null
#  key               :string(255)      not null
#  uploaded_at       :datetime
#  shared_at         :datetime
#  shared_expired_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require 'rails_helper'

RSpec.describe StorageFile, type: :model do
  describe "#shared?" do
    context "when shared_at is not set" do
      it "returns false" do
        storage_file = StorageFile.new
        expect(storage_file.shared?).to be_falsy
      end
    end

    context "when shared_at is set" do

      context "when shared_expired_at is past" do
        it "returns false" do
          storage_file = StorageFile.new(shared_at: Time.now, shared_expired_at: Time.now - 1.day)
          expect(storage_file.shared?).to be_falsy
        end
      end

      context "when shared_expired_at is not past" do
        it "returns true" do
          storage_file = StorageFile.new(shared_at: Time.now, shared_expired_at: Time.now + 1.day)
          expect(storage_file.shared?).to be_truthy
        end
      end
    end
  end
end

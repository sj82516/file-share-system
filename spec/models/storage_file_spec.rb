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

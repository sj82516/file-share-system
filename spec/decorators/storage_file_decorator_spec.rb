require 'rails_helper'

RSpec.describe StorageFileDecorator do
  describe "#share_link" do
    let(:storage_file) { create(:storage_file, :shared) }
    let(:decorator) { StorageFileDecorator.new(storage_file) }

    context "when file is shared" do
      it "returns share link" do
        expect(decorator.share_link.present?).to be_truthy
      end
    end

    context "when file is not shared" do
      let(:storage_file) { create(:storage_file) }

      it "returns empty string" do
        expect(decorator.share_link).to eq("")
      end
    end
  end
end

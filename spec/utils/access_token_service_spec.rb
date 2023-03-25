require 'rails_helper'

RSpec.describe ::AccessTokenService do
  let(:service) { ::AccessTokenService.new }
  let(:payload) { { "user_id"=> 1 } }
  let(:token) { service.encode(payload) }

  describe '#encode' do
    it 'returns a token' do
      expect(token).to be_a(String)
    end
  end

  describe '#decode' do
    it 'returns a hash' do
      expect(service.decode(token)).to be_a(Hash)
    end

    it 'returns the payload' do
      expect(service.decode(token)).to eq(payload)
    end

    it 'raises an error if the token is invalid' do
      expect { service.decode('invalid') }.to raise_error(AccessTokenService::DECODE_ERROR)
    end
  end
end

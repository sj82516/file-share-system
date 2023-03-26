class RandomStorageFileKeyGenerator
  class << self
    def generate
      SecureRandom.urlsafe_base64(20)
    end
  end
end

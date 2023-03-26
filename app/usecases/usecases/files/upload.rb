class Usecases::Files::Upload
  class ERROR_GENERATE_KEY < StandardError
  end

  class << self
    def run(file_name:, file_size:, file_type:, current_user:, try_times: 3)
      presigned_url = generate_file(file_name, file_size, file_type, current_user, try_times)
      raise ERROR_GENERATE_KEY if presigned_url.blank?

      presigned_url
    end

    private
    def generate_file(file_name, file_size, file_type, current_user, times)
      if times <= 0
        Rails.logger.error('Failed to generate file')
        return nil
      end

      begin
        key = RandomStorageFileKeyGenerator.generate

        #TODO use Bloom Filter to check collision. It would be much more efficient than using DB query
        storage_file = StorageFile.new(user: current_user, name: file_name, file_type: file_type, status: :init,
          size: file_size, key: key)
        storage_file.save!

        return S3StorageProvider.new.create_upload_presigned_url(current_user, key, file_type, file_size)
      rescue ActiveRecord::RecordNotUnique
        return generate_file(file_name, file_size, file_type, current_user, times - 1)
      end

      nil
    end
  end
end

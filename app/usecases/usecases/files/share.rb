class Usecases::Files::Share
  class ERROR_FILE_NOT_FOUND < StandardError
  end
  class ERROR_FILE_NOT_UPLOADED < StandardError
  end
  class ERROR_NOT_ALLOWED < StandardError
  end

  class << self
    def run(file_id:, current_user:)
      storage_file = StorageFile.find_by(id: file_id)
      raise ERROR_FILE_NOT_FOUND if storage_file.blank?
      raise ERROR_NOT_ALLOWED unless storage_file.user == current_user
      raise ERROR_FILE_NOT_UPLOADED unless storage_file.uploaded?

      S3StorageProvider.new.public_object(storage_file: storage_file)

      storage_file.shared_at = Time.now
      storage_file.shared_expired_at = Time.now + 1.day
      storage_file.save!

      storage_file
    end
  end
end

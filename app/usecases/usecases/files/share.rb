# User share a file to public
class Usecases::Files::Share
  SHARE_EXPIRE_DURATION = 1.day

  class ERROR_FILE_NOT_FOUND < StandardError;end
  # File should be uploaded before share
  class ERROR_FILE_NOT_UPLOADED < StandardError; end
  class ERROR_NOT_ALLOWED < StandardError;end

  class << self

    def run(file_id:, current_user:)
      storage_file = StorageFile.find_by(id: file_id)
      raise ERROR_FILE_NOT_FOUND if storage_file.blank?

      # prevent user share multiple times in a short period
      ActiveRecord::Base.transaction do
        storage_file.lock!

        raise ERROR_NOT_ALLOWED unless storage_file.user == current_user
        raise ERROR_FILE_NOT_UPLOADED unless storage_file.uploaded?
        return storage_file if storage_file.shared?

        S3StorageProvider.new.public_object(storage_file: storage_file)

        storage_file.shared_at = Time.now
        storage_file.shared_expired_at = Time.now + SHARE_EXPIRE_DURATION
        storage_file.save!

        storage_file
      end

      storage_file
    end
  end
end

class Usecases::Files::List

  class << self
    def run(current_user:)
      storage_files = StorageFile.where(user: current_user)
      signed_cookie = S3StorageProvider.new.signed_cookie_for_private_files(user: current_user)
      storage_files.map do |file|
        file.decorate(context: { signed_cookie: signed_cookie })
      end
    end
  end
end

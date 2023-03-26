class FilesController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def upload
    # extract file information from client
    # TODO validate file size and content type maybe?
    file_name = params[:file][:name]
    file_type = params[:file][:type]
    file_size = params[:file][:size]&.to_i

    presigned_url = S3StorageProvider.new.create_upload_presigned_url(current_user, file_name, file_type, file_size)
    key = RandomStorageFileKeyGenerator.generate

    storage_file = StorageFile.new(user: current_user, name: file_name, file_type: file_type, status: :init,
      size: file_size, key: key)
    storage_file.save!

    render json: { presigned_url: presigned_url }
  end

  def share
  end
end

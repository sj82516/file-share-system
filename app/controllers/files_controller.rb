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

    return render json: { error: 'file is invalid' }, status: :bad_request if file_name.blank? || file_type.blank? || file_size.blank?

    presigned_url = generate_file(file_name, file_size, file_type, 0)
    return render json: { error: 'failed to generate file' }, status: :internal_server_error if presigned_url.blank?

    render json: { presigned_url: presigned_url }
  end

  def generate_file(file_name, file_size, file_type, times)
    if times > 3
      Rails.logger.error('Failed to generate file')
      return nil
    end

    begin
      presigned_url = S3StorageProvider.new.create_upload_presigned_url(current_user, file_name, file_type, file_size)
      key = RandomStorageFileKeyGenerator.generate

      storage_file = StorageFile.new(user: current_user, name: file_name, file_type: file_type, status: :init,
        size: file_size, key: key)
      storage_file.save!
      presigned_url
    rescue ActiveRecord::RecordNotUnique
      generate_file(file_name, file_size, file_type, times + 1)
    end
  end

  def share
  end
end

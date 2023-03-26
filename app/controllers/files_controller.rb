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
      key = RandomStorageFileKeyGenerator.generate

      #TODO use Bloom Filter to check collision. It would be much more efficient than using DB query
      storage_file = StorageFile.new(user: current_user, name: file_name, file_type: file_type, status: :init,
        size: file_size, key: key)
      storage_file.save!

      return S3StorageProvider.new.create_upload_presigned_url(current_user, key, file_type, file_size)
    rescue ActiveRecord::RecordNotUnique
      return generate_file(file_name, file_size, file_type, times + 1)
    end

    nil
  end

  def share
  end
end

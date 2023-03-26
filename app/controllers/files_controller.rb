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

    begin
      presigned_url = Usecases::Files::Upload.run(file_name: file_name, file_type: file_type, file_size: file_size,
        current_user: current_user)
      render json: { presigned_url: presigned_url }
    rescue Exception => e
      Rails.logger.error(e)
      return render json: { error: 'failed to generate file' }, status: :internal_server_error
    end
  end

  def share
    file_id = params[:id]
    storage_file = StorageFile.find_by(id: file_id)
    return render json: { error: 'file is not found' }, status: :not_found if storage_file.blank?
    return render json: { error: 'file is not uploaded' }, status: :forbidden unless storage_file.uploaded?

    S3StorageProvider.new.public_object(storage_file: storage_file)
    render json: { share_link: 'public_url' }
  end
end

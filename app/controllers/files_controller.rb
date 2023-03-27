class FilesController < ApplicationController
  before_action :authenticate_user!

  def index
    storage_files = StorageFile.where(user: current_user)
    signed_cookie = S3StorageProvider.new.signed_cookie_for_private_files(user: current_user)
    render json: {
      files: storage_files.map do |file|
        f = file.decorate(context: { signed_cookie: signed_cookie })
        {
          **f.attributes,
          share_link: f.share_link,
          private_link: f.private_link
        }
      end
    }
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
    rescue Usecases::Files::Upload::ERROR_GENERATE_KEY => e
      Rails.logger.error(e)
      return render json: { error: 'failed to generate file' }, status: :internal_server_error
    end
  end

  def share
    file_id = params[:id]
    begin
      storage_file = Usecases::Files::Share.run(file_id: file_id, current_user: current_user)
      render json: { share_link: storage_file.decorate.share_link }
    rescue ::Usecases::Files::Share::ERROR_FILE_NOT_FOUND
      return render json: { error: 'file not found' }, status: :not_found
    rescue Usecases::Files::Share::ERROR_FILE_NOT_UPLOADED
      return render json: { error: 'file is not uploaded' }, status: :bad_request
    rescue Usecases::Files::Share::ERROR_NOT_ALLOWED
      return render json: { error: 'not allowed' }, status: :forbidden
    end
  end
end

class S3StorageProvider
  PRIVATE_BUCKET = ENV['AWS_STORAGE_FILE_PRIVATE_BUCKET']

  def initialize
    @aws_config = Rails.application.credentials.aws
    @client = Aws::S3::Client.new({
      access_key_id: @aws_config[:access_key_id],
      secret_access_key: @aws_config[:secret_access_key]
    })
  end

  # restrict file size to prevent user from uploading large files
  def create_upload_presigned_url(user, file_name, file_type, file_size)
    signer = Aws::S3::Presigner.new(client: @client)
    object_key = "storage_files/#{user.id}/#{file_name}"
    signer.presigned_url(:put_object, bucket: PRIVATE_BUCKET, key: object_key, expires_in: 600, content_type: file_type,
      content_length: file_size)
  end
end

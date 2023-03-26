class S3StorageProvider
  PRIVATE_BUCKET = ENV['AWS_STORAGE_FILE_PRIVATE_BUCKET']
  PUBLIC_BUCKET = ENV['AWS_STORAGE_FILE_PUBLIC_BUCKET']

  def initialize
    @aws_config = Rails.application.credentials.aws
    @client = Aws::S3::Client.new({
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    })
  end

  # restrict file size to prevent user from uploading large files
  def create_upload_presigned_url(user, file_name, file_type, file_size)
    signer = Aws::S3::Presigner.new(client: @client)
    object_key = "storage_files/#{user.id}/#{file_name}"
    signer.presigned_url(:put_object, bucket: PRIVATE_BUCKET, key: object_key, expires_in: 600, content_type: file_type,
      content_length: file_size)
  end

  def public_object(storage_file)
    object_key = "storage_files/#{storage_file.user.id}/#{storage_file.key}"
    shared_object_key = "#{storage_file.key}"
    @client.copy_object({
      bucket: PUBLIC_BUCKET,
      copy_source: "#{PRIVATE_BUCKET}/#{object_key}",
      key: shared_object_key
    })
    storage_file.update!(status: :shared)
  end
end

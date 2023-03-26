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

  def public_object(storage_file:)
    object_key = "storage_files/#{storage_file.user.id}/#{storage_file.key}"
    shared_object_key = "share/#{storage_file.key}"

    @client.copy_object({
      bucket: PUBLIC_BUCKET,
      copy_source: "#{PRIVATE_BUCKET}/#{object_key}",
      key: shared_object_key
    })
  end

  def signed_cookie_for_private_files(user:)
    key_pair_id = ENV["AWS_SIGNED_COOKIE_KEY_PAIR_ID"]
    private_key = OpenSSL::PKey::RSA.new(File.read("config/private_key.pem"))
    resource_url = "#{ENV['PRIVATE_CDN_HOST_NAME']}storage_files/#{user.id}/*"

    # Generate policy statement
    expired_at = Time.now.to_i + 600
    policy = {
      Statement: [
        {
          Resource: resource_url,
          Condition: {
            "DateLessThan": {
              "AWS:EpochTime": expired_at
            }
          }
        }
      ]
    }.to_json

    # Create CloudFront signer
    signer = Aws::CloudFront::CookieSigner.new(private_key: private_key, key_pair_id: key_pair_id)
    # Sign the policy statement
    signature = signer.signed_cookie(resource_url, policy: policy)
    {
      "Key-Pair-Id" => key_pair_id,
      "Policy" => signature["CloudFront-Policy"],
      "Signature" => signature["CloudFront-Signature"],
      "Expires" => expired_at
    }
  end
end

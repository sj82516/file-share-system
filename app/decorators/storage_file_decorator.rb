class StorageFileDecorator < Draper::Decorator
  delegate_all

  def share_link
    "#{ENV['PUBLIC_CDN_HOSTNAME']}share/#{key}"
  end
end

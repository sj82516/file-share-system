class StorageFileDecorator < Draper::Decorator
  delegate_all
  delegate :share_link, to: :object
  delegate :private_link, to: :object

  def share_link
    return "" if shared?
    "#{ENV['PUBLIC_CDN_HOSTNAME']}share/#{key}"
  end

  def private_link
    return "" if context[:signed_cookie].blank?
    "#{ENV['PRIVATE_CDN_HOSTNAME']}storage_files/#{user.id}/#{key}?#{context[:signed_cookie].to_query}"
  end
end

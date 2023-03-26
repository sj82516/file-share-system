class StorageFile < ApplicationRecord
  belongs_to :user

  enum status: { init: 0, uploaded: 1 }

  def shared?
    shared_at.present? && shared_expired_at.present? && shared_expired_at > Time.now
  end
end

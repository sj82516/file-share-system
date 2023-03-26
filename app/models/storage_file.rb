class StorageFile < ApplicationRecord
  belongs_to :user

  enum status: { init: 0, uploaded: 1}
end

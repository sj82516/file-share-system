# == Schema Information
#
# Table name: storage_files
#
#  id                :bigint           not null, primary key
#  user_id           :integer          not null
#  status            :integer          default("init"), not null
#  name              :string(255)      not null
#  file_type         :string(255)      not null
#  size              :string(255)      not null
#  key               :string(255)      not null
#  uploaded_at       :datetime
#  shared_at         :datetime
#  shared_expired_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class StorageFile < ApplicationRecord
  belongs_to :user

  enum status: { init: 0, uploaded: 1 }

  def shared?
    return false unless shared_at.present?
    return false unless shared_expired_at.present? && shared_expired_at > Time.now
    true
  end
end

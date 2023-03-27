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
FactoryBot.define do
  factory :storage_file do
    file_type { "text" }
    name { "test.txt" }
    size { 10 }
    key { "key" }

    trait :shared do
      status { :uploaded }
      shared_at { Time.now }
      shared_expired_at { Time.now + 1.day }
    end

    trait :share_expired do
      status { :uploaded }
      shared_at { Time.now - 5.days }
      shared_expired_at { Time.now - 4.day }
    end
  end
end

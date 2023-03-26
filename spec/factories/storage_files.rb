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

FactoryBot.define do
  factory :storage_file do
    file_type { "text" }
    name { "test.txt" }
    size { 10 }
    key { "key" }
  end
end

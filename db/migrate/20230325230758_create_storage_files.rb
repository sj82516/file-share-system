class CreateStorageFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :storage_files do |t|
      t.integer :user_id, null: false
      t.integer :status, null: false, default: 0
      t.string :name, null: false
      t.string :file_type, null: false
      t.string :size, null: false
      t.string :key, null: false

      t.timestamp :uploaded_at
      t.timestamp :shared_at
      t.timestamp :shared_expired_at

      t.timestamps
    end

    add_index :storage_files, :user_id
    add_index :storage_files, :key, unique: true
  end
end

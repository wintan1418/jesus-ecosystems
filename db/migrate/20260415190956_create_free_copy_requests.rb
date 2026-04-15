class CreateFreeCopyRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :free_copy_requests do |t|
      t.string :first_name,      null: false
      t.string :last_name,       null: false
      t.string :email,           null: false
      t.string :phone

      t.string :address_line_1,  null: false
      t.string :address_line_2
      t.string :city,            null: false
      t.string :state_province,  null: false
      t.string :postal_code,     null: false
      t.string :country,         null: false

      t.string  :volumes_requested, array: true, null: false, default: []
      t.string  :locale,            null: false
      t.string  :status,            null: false, default: "pending"
      t.text    :notes
      t.string  :ip_address

      t.timestamps
    end
    add_index :free_copy_requests, :status
    add_index :free_copy_requests, :country
    add_index :free_copy_requests, :locale
    add_index :free_copy_requests, :email
    add_index :free_copy_requests, :created_at
  end
end

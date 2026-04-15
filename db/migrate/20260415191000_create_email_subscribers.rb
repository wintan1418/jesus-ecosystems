class CreateEmailSubscribers < ActiveRecord::Migration[8.1]
  def change
    create_table :email_subscribers do |t|
      t.string :email,           null: false
      t.string :first_name
      t.string :locale,          null: false, default: "en"
      t.string :source
      t.datetime :confirmed_at
      t.datetime :unsubscribed_at

      t.timestamps
    end
    add_index :email_subscribers, :email,  unique: true
    add_index :email_subscribers, :locale
    add_index :email_subscribers, :source
  end
end

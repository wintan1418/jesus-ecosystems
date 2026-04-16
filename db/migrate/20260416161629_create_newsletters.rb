class CreateNewsletters < ActiveRecord::Migration[8.1]
  def change
    create_table :newsletters do |t|
      t.string  :subject,    null: false
      t.string  :preheader
      t.string  :locale,     null: false, default: "en"
      t.datetime :scheduled_for
      t.datetime :sent_at
      t.integer :recipients_count, null: false, default: 0

      # Reference admins (no FK to admins table — keep it simple, nullable for
      # historical preservation if an admin is ever deleted).
      t.bigint  :sent_by_id

      t.timestamps
    end
    add_index :newsletters, :locale
    add_index :newsletters, :sent_at
    add_index :newsletters, :scheduled_for
    add_index :newsletters, :sent_by_id
  end
end

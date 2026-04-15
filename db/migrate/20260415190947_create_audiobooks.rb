class CreateAudiobooks < ActiveRecord::Migration[8.1]
  def change
    create_table :audiobooks do |t|
      t.references :book, null: false, foreign_key: true
      t.string  :locale,           null: false
      t.string  :title,            null: false
      t.integer :duration_seconds
      t.integer :position,         null: false, default: 0

      t.timestamps
    end
    add_index :audiobooks, [:book_id, :locale], unique: true
    add_index :audiobooks, [:book_id, :position]
  end
end

class CreateChapters < ActiveRecord::Migration[8.1]
  def change
    create_table :chapters do |t|
      t.references :book, null: false, foreign_key: true
      t.string  :title,      null: false
      t.text    :body
      t.integer :position,   null: false, default: 0
      t.boolean :is_preview, null: false, default: false
      t.string  :locale,     null: false
      t.string  :slug,       null: false

      t.timestamps
    end
    add_index :chapters, [:book_id, :locale, :slug], unique: true
    add_index :chapters, [:book_id, :position]
    add_index :chapters, :is_preview
  end
end

class CreateBookTranslations < ActiveRecord::Migration[8.1]
  def change
    create_table :book_translations do |t|
      t.references :book, null: false, foreign_key: true
      t.string :locale,      null: false
      t.string :title,       null: false
      t.text   :description
      t.string :tagline
      t.string :slug,        null: false

      t.timestamps
    end
    add_index :book_translations, [:book_id, :locale], unique: true
    add_index :book_translations, [:locale, :slug],    unique: true
  end
end

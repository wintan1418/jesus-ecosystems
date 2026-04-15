class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string  :title,         null: false
      t.integer :volume_number, null: false
      t.string  :slug,          null: false
      t.text    :description
      t.string  :tagline
      t.datetime :published_at
      t.integer :position,      null: false, default: 0

      t.timestamps
    end
    add_index :books, :slug,          unique: true
    add_index :books, :volume_number, unique: true
    add_index :books, :position
  end
end

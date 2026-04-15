class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :slug
      t.text :excerpt
      t.string :locale
      t.datetime :published_at
      t.integer :reading_minutes
      t.string :author_name
      t.string :tags
      t.integer :position

      t.timestamps
    end
    add_index :posts, :slug, unique: true
  end
end

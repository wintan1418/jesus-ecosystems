class CreateEpisodes < ActiveRecord::Migration[8.1]
  def change
    create_table :episodes do |t|
      t.string  :title,       null: false
      t.string  :slug,        null: false
      t.text    :description
      t.integer :season,      null: false, default: 1
      t.integer :number
      t.integer :duration_seconds
      t.datetime :published_at
      t.string  :locale,      null: false, default: "en"
      t.boolean :explicit,    null: false, default: false
      t.integer :position,    null: false, default: 0

      t.timestamps
    end
    add_index :episodes, :slug, unique: true
    add_index :episodes, :locale
    add_index :episodes, :published_at
    add_index :episodes, [:season, :number]
  end
end

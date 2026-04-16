# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_16_145519) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.bigint "user_id"
    t.bigint "visit_id"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "app_version"
    t.string "browser"
    t.string "city"
    t.string "country"
    t.string "device_type"
    t.string "ip"
    t.text "landing_page"
    t.float "latitude"
    t.float "longitude"
    t.string "os"
    t.string "os_version"
    t.string "platform"
    t.text "referrer"
    t.string "referring_domain"
    t.string "region"
    t.datetime "started_at"
    t.text "user_agent"
    t.bigint "user_id"
    t.string "utm_campaign"
    t.string "utm_content"
    t.string "utm_medium"
    t.string "utm_source"
    t.string "utm_term"
    t.string "visit_token"
    t.string "visitor_token"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
    t.index ["visitor_token", "started_at"], name: "index_ahoy_visits_on_visitor_token_and_started_at"
  end

  create_table "audiobooks", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.integer "duration_seconds"
    t.string "locale", null: false
    t.integer "position", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id", "locale"], name: "index_audiobooks_on_book_id_and_locale", unique: true
    t.index ["book_id", "position"], name: "index_audiobooks_on_book_id_and_position"
    t.index ["book_id"], name: "index_audiobooks_on_book_id"
  end

  create_table "book_translations", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "locale", null: false
    t.string "slug", null: false
    t.string "tagline"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id", "locale"], name: "index_book_translations_on_book_id_and_locale", unique: true
    t.index ["book_id"], name: "index_book_translations_on_book_id"
    t.index ["locale", "slug"], name: "index_book_translations_on_locale_and_slug", unique: true
  end

  create_table "books", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.datetime "published_at"
    t.string "slug", null: false
    t.string "tagline"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "volume_number", null: false
    t.index ["position"], name: "index_books_on_position"
    t.index ["slug"], name: "index_books_on_slug", unique: true
    t.index ["volume_number"], name: "index_books_on_volume_number", unique: true
  end

  create_table "chapters", force: :cascade do |t|
    t.text "body"
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.boolean "is_preview", default: false, null: false
    t.string "locale", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id", "locale", "slug"], name: "index_chapters_on_book_id_and_locale_and_slug", unique: true
    t.index ["book_id", "position"], name: "index_chapters_on_book_id_and_position"
    t.index ["book_id"], name: "index_chapters_on_book_id"
    t.index ["is_preview"], name: "index_chapters_on_is_preview"
  end

  create_table "email_subscribers", force: :cascade do |t|
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name"
    t.string "locale", default: "en", null: false
    t.string "source"
    t.datetime "unsubscribed_at"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_email_subscribers_on_email", unique: true
    t.index ["locale"], name: "index_email_subscribers_on_locale"
    t.index ["source"], name: "index_email_subscribers_on_source"
  end

  create_table "episodes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duration_seconds"
    t.boolean "explicit", default: false, null: false
    t.string "locale", default: "en", null: false
    t.integer "number"
    t.integer "position", default: 0, null: false
    t.datetime "published_at"
    t.integer "season", default: 1, null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["locale"], name: "index_episodes_on_locale"
    t.index ["published_at"], name: "index_episodes_on_published_at"
    t.index ["season", "number"], name: "index_episodes_on_season_and_number"
    t.index ["slug"], name: "index_episodes_on_slug", unique: true
  end

  create_table "free_copy_requests", force: :cascade do |t|
    t.string "address_line_1", null: false
    t.string "address_line_2"
    t.string "city", null: false
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name", null: false
    t.string "ip_address"
    t.string "last_name", null: false
    t.string "locale", null: false
    t.text "notes"
    t.string "phone"
    t.string "postal_code", null: false
    t.integer "qty_vol_1", default: 0, null: false
    t.integer "qty_vol_1_combo", default: 0, null: false
    t.string "state_province", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.string "volumes_requested", default: [], null: false, array: true
    t.index ["country"], name: "index_free_copy_requests_on_country"
    t.index ["created_at"], name: "index_free_copy_requests_on_created_at"
    t.index ["email"], name: "index_free_copy_requests_on_email"
    t.index ["locale"], name: "index_free_copy_requests_on_locale"
    t.index ["status"], name: "index_free_copy_requests_on_status"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "noticed_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "notifications_count"
    t.jsonb "params"
    t.bigint "record_id"
    t.string "record_type"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "read_at", precision: nil
    t.bigint "recipient_id", null: false
    t.string "recipient_type", null: false
    t.datetime "seen_at", precision: nil
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "posts", force: :cascade do |t|
    t.string "author_name"
    t.datetime "created_at", null: false
    t.text "excerpt"
    t.string "locale"
    t.integer "position"
    t.datetime "published_at"
    t.integer "reading_minutes"
    t.string "slug"
    t.string "tags"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_posts_on_slug", unique: true
  end

  create_table "site_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["key"], name: "index_site_settings_on_key", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audiobooks", "books"
  add_foreign_key "book_translations", "books"
  add_foreign_key "chapters", "books"
end

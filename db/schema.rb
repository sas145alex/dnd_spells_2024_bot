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

ActiveRecord::Schema[7.2].define(version: 2024_09_16_094230) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "spells", force: :cascade do |t|
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.string "title", null: false
    t.string "description", null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "responsible_id"
    t.index ["created_by_id"], name: "index_spells_on_created_by_id"
    t.index ["published_at"], name: "index_spells_on_published_at", where: "(published_at IS NOT NULL)"
    t.index ["responsible_id"], name: "index_spells_on_responsible_id"
    t.index ["title"], name: "index_spells_on_title"
    t.index ["title"], name: "index_spells_on_title_gin", opclass: :gin_trgm_ops, using: :gin
    t.index ["updated_by_id"], name: "index_spells_on_updated_by_id"
  end

  add_foreign_key "spells", "admin_users", column: "created_by_id"
  add_foreign_key "spells", "admin_users", column: "responsible_id"
  add_foreign_key "spells", "admin_users", column: "updated_by_id"
end

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

ActiveRecord::Schema[7.2].define(version: 2024_11_28_143529) do
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

  create_table "bot_commands", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_bot_commands_on_title", unique: true
  end

  create_table "character_klass_abilities", force: :cascade do |t|
    t.string "title", null: false
    t.string "original_title"
    t.text "description", default: "", null: false
    t.integer "levels", default: [], null: false, array: true
    t.datetime "published_at"
    t.bigint "character_klass_id", null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_klass_id"], name: "index_character_klass_abilities_on_character_klass_id"
    t.index ["created_by_id"], name: "index_character_klass_abilities_on_created_by_id"
    t.index ["updated_by_id"], name: "index_character_klass_abilities_on_updated_by_id"
  end

  create_table "character_klasses", force: :cascade do |t|
    t.string "title", null: false
    t.string "original_title"
    t.text "description", default: "", null: false
    t.bigint "parent_klass_id"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_character_klasses_on_created_by_id"
    t.index ["parent_klass_id"], name: "index_character_klasses_on_parent_klass_id"
    t.index ["updated_by_id"], name: "index_character_klasses_on_updated_by_id"
  end

  create_table "characteristics", force: :cascade do |t|
    t.string "title", null: false
    t.string "original_title"
    t.text "description", default: "", null: false
    t.datetime "published_at"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_characteristics_on_created_by_id"
    t.index ["updated_by_id"], name: "index_characteristics_on_updated_by_id"
  end

  create_table "creatures", force: :cascade do |t|
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.bigint "responsible_id"
    t.string "title", null: false
    t.string "original_title"
    t.string "description", null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_creatures_on_created_by_id"
    t.index ["published_at"], name: "index_creatures_on_published_at", where: "(published_at IS NOT NULL)"
    t.index ["responsible_id"], name: "index_creatures_on_responsible_id"
    t.index ["title"], name: "index_creatures_on_title"
    t.index ["title"], name: "index_creatures_on_title_gin", opclass: :gin_trgm_ops, using: :gin
    t.index ["updated_by_id"], name: "index_creatures_on_updated_by_id"
  end

  create_table "equipment_items", force: :cascade do |t|
    t.string "title", null: false
    t.string "original_title"
    t.text "description", default: "", null: false
    t.datetime "published_at"
    t.string "item_type", null: false, comment: "enum"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_equipment_items_on_created_by_id"
    t.index ["updated_by_id"], name: "index_equipment_items_on_updated_by_id"
  end

  create_table "feats", force: :cascade do |t|
    t.string "title", null: false
    t.string "original_title"
    t.text "description", default: "", null: false
    t.string "category", null: false
    t.datetime "published_at"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_feats_on_created_by_id"
    t.index ["updated_by_id"], name: "index_feats_on_updated_by_id"
  end

  create_table "glossary_categories", force: :cascade do |t|
    t.string "title", null: false
    t.string "original_title"
    t.bigint "parent_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_category_id"], name: "index_glossary_categories_on_parent_category_id"
  end

  create_table "glossary_items", force: :cascade do |t|
    t.string "title", null: false
    t.string "original_title"
    t.text "description", default: "", null: false
    t.bigint "category_id", null: false
    t.datetime "published_at"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_glossary_items_on_category_id"
    t.index ["created_by_id"], name: "index_glossary_items_on_created_by_id"
    t.index ["updated_by_id"], name: "index_glossary_items_on_updated_by_id"
  end

  create_table "invocations", force: :cascade do |t|
    t.string "title", null: false
    t.string "original_title"
    t.text "description", default: "", null: false
    t.integer "level", default: 1, null: false
    t.datetime "published_at"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_invocations_on_created_by_id"
    t.index ["updated_by_id"], name: "index_invocations_on_updated_by_id"
  end

  create_table "maneuvers", force: :cascade do |t|
    t.string "title", null: false
    t.string "original_title"
    t.text "description", default: "", null: false
    t.datetime "published_at"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_maneuvers_on_created_by_id"
    t.index ["updated_by_id"], name: "index_maneuvers_on_updated_by_id"
  end

  create_table "mentions", force: :cascade do |t|
    t.string "mentionable_type"
    t.bigint "mentionable_id"
    t.string "another_mentionable_type"
    t.bigint "another_mentionable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["another_mentionable_type", "another_mentionable_id"], name: "index_mentions_on_another_mentionable"
    t.index ["mentionable_id", "mentionable_type", "another_mentionable_type", "another_mentionable_id"], name: "index_mentions_on_mentionable", unique: true
  end

  create_table "message_distributions", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.datetime "last_sent_at"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_message_distributions_on_created_by_id"
    t.index ["updated_by_id"], name: "index_message_distributions_on_updated_by_id"
  end

  create_table "metamagics", force: :cascade do |t|
    t.string "title", null: false
    t.string "original_title"
    t.text "description", default: "", null: false
    t.integer "sorcery_points", default: 1, null: false
    t.datetime "published_at"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_metamagics_on_created_by_id"
    t.index ["updated_by_id"], name: "index_metamagics_on_updated_by_id"
  end

  create_table "origins", force: :cascade do |t|
    t.string "title", null: false
    t.string "original_title"
    t.text "description", default: "", null: false
    t.datetime "published_at"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_origins_on_created_by_id"
    t.index ["updated_by_id"], name: "index_origins_on_updated_by_id"
  end

  create_table "races", force: :cascade do |t|
    t.string "title", null: false
    t.string "original_title"
    t.text "description", default: "", null: false
    t.datetime "published_at"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_races_on_created_by_id"
    t.index ["updated_by_id"], name: "index_races_on_updated_by_id"
  end

  create_table "segments", force: :cascade do |t|
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "attribute_resource_type"
    t.bigint "attribute_resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attribute_resource_type", "attribute_resource_id"], name: "index_segments_on_attribute_resource"
    t.index ["resource_id", "resource_type", "attribute_resource_type", "attribute_resource_id"], name: "index_segments_on_resource", unique: true
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
    t.string "original_title"
    t.integer "requested_count", default: 0, null: false
    t.integer "level", default: 0, null: false
    t.string "school", comment: "enum"
    t.index ["created_by_id"], name: "index_spells_on_created_by_id"
    t.index ["published_at"], name: "index_spells_on_published_at", where: "(published_at IS NOT NULL)"
    t.index ["responsible_id"], name: "index_spells_on_responsible_id"
    t.index ["title"], name: "index_spells_on_title"
    t.index ["title"], name: "index_spells_on_title_gin", opclass: :gin_trgm_ops, using: :gin
    t.index ["updated_by_id"], name: "index_spells_on_updated_by_id"
  end

  create_table "spells_character_klasses", force: :cascade do |t|
    t.bigint "spell_id", null: false
    t.bigint "character_klass_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_klass_id"], name: "index_spells_character_klasses_on_character_klass_id"
    t.index ["spell_id", "character_klass_id"], name: "idx_on_spell_id_character_klass_id_549ccbeb87", unique: true
    t.index ["spell_id"], name: "index_spells_character_klasses_on_spell_id"
  end

  create_table "telegram_users", force: :cascade do |t|
    t.bigint "external_id", null: false
    t.datetime "last_seen_at"
    t.integer "command_requested_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.bigint "chat_id"
    t.index ["chat_id"], name: "index_telegram_users_on_chat_id"
    t.index ["external_id"], name: "index_telegram_users_on_external_id", unique: true
    t.index ["last_seen_at"], name: "index_telegram_users_on_last_seen_at"
  end

  create_table "tools", force: :cascade do |t|
    t.string "title", null: false
    t.string "original_title"
    t.text "description", default: "", null: false
    t.datetime "published_at"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_tools_on_created_by_id"
    t.index ["updated_by_id"], name: "index_tools_on_updated_by_id"
  end

  create_table "wild_magics", force: :cascade do |t|
    t.int4range "roll", null: false
    t.text "description", null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_wild_magics_on_created_by_id"
    t.index ["roll"], name: "index_wild_magics_on_roll", unique: true
    t.index ["updated_by_id"], name: "index_wild_magics_on_updated_by_id"
  end

  add_foreign_key "character_klass_abilities", "admin_users", column: "created_by_id"
  add_foreign_key "character_klass_abilities", "admin_users", column: "updated_by_id"
  add_foreign_key "character_klass_abilities", "character_klasses"
  add_foreign_key "character_klasses", "admin_users", column: "created_by_id"
  add_foreign_key "character_klasses", "admin_users", column: "updated_by_id"
  add_foreign_key "character_klasses", "character_klasses", column: "parent_klass_id"
  add_foreign_key "characteristics", "admin_users", column: "created_by_id"
  add_foreign_key "characteristics", "admin_users", column: "updated_by_id"
  add_foreign_key "creatures", "admin_users", column: "created_by_id"
  add_foreign_key "creatures", "admin_users", column: "responsible_id"
  add_foreign_key "creatures", "admin_users", column: "updated_by_id"
  add_foreign_key "equipment_items", "admin_users", column: "created_by_id"
  add_foreign_key "equipment_items", "admin_users", column: "updated_by_id"
  add_foreign_key "feats", "admin_users", column: "created_by_id"
  add_foreign_key "feats", "admin_users", column: "updated_by_id"
  add_foreign_key "glossary_categories", "glossary_categories", column: "parent_category_id"
  add_foreign_key "glossary_items", "admin_users", column: "created_by_id"
  add_foreign_key "glossary_items", "admin_users", column: "updated_by_id"
  add_foreign_key "glossary_items", "glossary_categories", column: "category_id"
  add_foreign_key "invocations", "admin_users", column: "created_by_id"
  add_foreign_key "invocations", "admin_users", column: "updated_by_id"
  add_foreign_key "maneuvers", "admin_users", column: "created_by_id"
  add_foreign_key "maneuvers", "admin_users", column: "updated_by_id"
  add_foreign_key "message_distributions", "admin_users", column: "created_by_id"
  add_foreign_key "message_distributions", "admin_users", column: "updated_by_id"
  add_foreign_key "metamagics", "admin_users", column: "created_by_id"
  add_foreign_key "metamagics", "admin_users", column: "updated_by_id"
  add_foreign_key "origins", "admin_users", column: "created_by_id"
  add_foreign_key "origins", "admin_users", column: "updated_by_id"
  add_foreign_key "races", "admin_users", column: "created_by_id"
  add_foreign_key "races", "admin_users", column: "updated_by_id"
  add_foreign_key "spells", "admin_users", column: "created_by_id"
  add_foreign_key "spells", "admin_users", column: "responsible_id"
  add_foreign_key "spells", "admin_users", column: "updated_by_id"
  add_foreign_key "spells_character_klasses", "character_klasses"
  add_foreign_key "spells_character_klasses", "spells"
  add_foreign_key "tools", "admin_users", column: "created_by_id"
  add_foreign_key "tools", "admin_users", column: "updated_by_id"
  add_foreign_key "wild_magics", "admin_users", column: "created_by_id"
  add_foreign_key "wild_magics", "admin_users", column: "updated_by_id"
end

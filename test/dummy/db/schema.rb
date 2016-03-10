# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160215000000) do

  create_table "auth_sessions", force: :cascade do |t|
    t.string   "credentials", limit: 255, null: false
    t.integer  "user_id",     limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "auth_sessions", ["credentials"], name: "index_auth_sessions_on_credentials", unique: true, using: :btree
  add_index "auth_sessions", ["user_id"], name: "index_auth_sessions_on_user_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "departments", force: :cascade do |t|
    t.string   "name",       limit: 255,                 null: false
    t.boolean  "inactive",               default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", force: :cascade do |t|
    t.integer  "topic_id",          limit: 4
    t.string   "item_file_name",    limit: 255
    t.string   "item_content_type", limit: 255
    t.integer  "item_file_size",    limit: 4
    t.datetime "item_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "documents", ["topic_id"], name: "index_documents_on_topic_id", using: :btree

  create_table "occurrences", force: :cascade do |t|
    t.integer  "session_id", limit: 4, null: false
    t.datetime "time",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "occurrences", ["session_id", "time"], name: "unique_occurrence_times_in_session", unique: true, using: :btree
  add_index "occurrences", ["session_id"], name: "index_occurrences_on_session_id", using: :btree

  create_table "permissions", force: :cascade do |t|
    t.integer  "department_id", limit: 4
    t.integer  "user_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["department_id"], name: "index_permissions_on_department_id", using: :btree
  add_index "permissions", ["user_id"], name: "index_permissions_on_user_id", using: :btree

  create_table "reservations", force: :cascade do |t|
    t.integer  "user_id",                limit: 4,                     null: false
    t.integer  "session_id",             limit: 4,                     null: false
    t.boolean  "cancelled",                            default: false
    t.integer  "attended",               limit: 4,     default: 0
    t.text     "special_accommodations", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reservations", ["session_id", "user_id"], name: "index_reservations_on_session_id_and_user_id", unique: true, using: :btree
  add_index "reservations", ["session_id"], name: "index_reservations_on_session_id", using: :btree
  add_index "reservations", ["user_id"], name: "index_reservations_on_user_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.integer  "topic_id",           limit: 4,                   null: false
    t.boolean  "cancelled",                      default: false, null: false
    t.string   "location",           limit: 255,                 null: false
    t.string   "location_url",       limit: 255
    t.integer  "site_id",            limit: 4
    t.integer  "seats",              limit: 4
    t.datetime "reg_start"
    t.datetime "reg_end"
    t.boolean  "survey_sent",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reservations_count", limit: 4,   default: 0,     null: false
  end

  add_index "sessions", ["site_id"], name: "index_sessions_on_site_id", using: :btree
  add_index "sessions", ["topic_id"], name: "index_sessions_on_topic_id", using: :btree

  create_table "sessions_users", id: false, force: :cascade do |t|
    t.integer "user_id",    limit: 4, null: false
    t.integer "session_id", limit: 4, null: false
  end

  add_index "sessions_users", ["session_id"], name: "index_sessions_users_on_session_id", using: :btree
  add_index "sessions_users", ["user_id"], name: "index_sessions_users_on_user_id", using: :btree

  create_table "sites", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_responses", force: :cascade do |t|
    t.integer  "reservation_id",    limit: 4,     null: false
    t.integer  "class_rating",      limit: 4
    t.integer  "instructor_rating", limit: 4
    t.integer  "applicability",     limit: 4
    t.text     "most_useful",       limit: 65535
    t.text     "comments",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_responses", ["reservation_id"], name: "index_survey_responses_on_reservation_id", unique: true, using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "topics", force: :cascade do |t|
    t.string   "name",          limit: 255,                   null: false
    t.text     "description",   limit: 65535
    t.string   "url",           limit: 255
    t.integer  "minutes",       limit: 4
    t.boolean  "inactive",                    default: false
    t.boolean  "certificate",                 default: false
    t.integer  "survey_type",   limit: 4,     default: 1
    t.string   "survey_url",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "department_id", limit: 4
  end

  add_index "topics", ["department_id"], name: "index_topics_on_department_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login",       limit: 255,                 null: false
    t.string   "email",       limit: 255,                 null: false
    t.string   "first_name",  limit: 255
    t.string   "last_name",   limit: 255,                 null: false
    t.string   "name_prefix", limit: 255
    t.string   "title",       limit: 255
    t.string   "department",  limit: 255
    t.boolean  "admin",                   default: false, null: false
    t.boolean  "boolean",                 default: false, null: false
    t.boolean  "manual",                  default: false, null: false
    t.boolean  "inactive",                default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["first_name"], name: "index_users_on_first_name", using: :btree
  add_index "users", ["last_name"], name: "index_users_on_last_name", using: :btree
  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255,   null: false
    t.integer  "item_id",    limit: 4,     null: false
    t.string   "event",      limit: 255,   null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object",     limit: 65535
    t.datetime "created_at"
    t.string   "ip",         limit: 255
    t.text     "user_agent", limit: 65535
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end

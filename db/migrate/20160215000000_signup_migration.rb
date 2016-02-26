class SignupMigration < ActiveRecord::Migration
  def change

    create_table "auth_sessions", force: true do |t|
      t.string   "credentials", null: false
      t.integer  "user_id",     null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "auth_sessions", ["credentials"], name: "index_auth_sessions_on_credentials", unique: true, using: :btree
    add_index "auth_sessions", ["user_id"], name: "index_auth_sessions_on_user_id", using: :btree

    create_table "delayed_jobs", force: true do |t|
      t.integer  "priority",   default: 0, null: false
      t.integer  "attempts",   default: 0, null: false
      t.text     "handler",                null: false
      t.text     "last_error"
      t.datetime "run_at"
      t.datetime "locked_at"
      t.datetime "failed_at"
      t.string   "locked_by"
      t.string   "queue"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

    create_table "departments", force: true do |t|
      t.string   "name",                       null: false
      t.boolean  "inactive",   default: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "documents", force: true do |t|
      t.integer  "topic_id"
      t.string   "item_file_name"
      t.string   "item_content_type"
      t.integer  "item_file_size"
      t.datetime "item_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "documents", ["topic_id"], name: "index_documents_on_topic_id", using: :btree

    create_table "occurrences", force: true do |t|
      t.integer  "session_id", null: false
      t.datetime "time",       null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "occurrences", ["session_id", "time"], name: "unique_occurrence_times_in_session", unique: true, using: :btree
    add_index "occurrences", ["session_id"], name: "index_occurrences_on_session_id", using: :btree

    create_table "permissions", force: true do |t|
      t.integer  "department_id"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "permissions", ["department_id"], name: "index_permissions_on_department_id", using: :btree
    add_index "permissions", ["user_id"], name: "index_permissions_on_user_id", using: :btree

    create_table "reservations", force: true do |t|
      t.integer  "user_id",                                null: false
      t.integer  "session_id",                             null: false
      t.boolean  "cancelled",              default: false
      t.integer  "attended",               default: 0
      t.text     "special_accommodations"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "reservations", ["session_id", "user_id"], name: "index_reservations_on_session_id_and_user_id", unique: true, using: :btree
    add_index "reservations", ["session_id"], name: "index_reservations_on_session_id", using: :btree
    add_index "reservations", ["user_id"], name: "index_reservations_on_user_id", using: :btree

    create_table "sessions", force: true do |t|
      t.integer  "topic_id",                           null: false
      t.boolean  "cancelled",          default: false, null: false
      t.string   "location",                           null: false
      t.string   "location_url"
      t.integer  "site_id"
      t.integer  "seats"
      t.datetime "reg_start"
      t.datetime "reg_end"
      t.boolean  "survey_sent",        default: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "reservations_count", default: 0,     null: false
    end

    add_index "sessions", ["site_id"], name: "index_sessions_on_site_id", using: :btree
    add_index "sessions", ["topic_id"], name: "index_sessions_on_topic_id", using: :btree

    create_table "sessions_users", id: false, force: true do |t|
      t.integer "user_id",    null: false
      t.integer "session_id", null: false
    end

    add_index "sessions_users", ["session_id"], name: "index_sessions_users_on_session_id", using: :btree
    add_index "sessions_users", ["user_id"], name: "index_sessions_users_on_user_id", using: :btree

    create_table "sites", force: true do |t|
      t.string   "name",       null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "survey_responses", force: true do |t|
      t.integer  "reservation_id",    null: false
      t.integer  "class_rating"
      t.integer  "instructor_rating"
      t.integer  "applicability"
      t.text     "most_useful"
      t.text     "comments"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "survey_responses", ["reservation_id"], name: "index_survey_responses_on_reservation_id", unique: true, using: :btree

    create_table "taggings", force: true do |t|
      t.integer  "tag_id"
      t.integer  "taggable_id"
      t.string   "taggable_type"
      t.integer  "tagger_id"
      t.string   "tagger_type"
      t.string   "context",       limit: 128
      t.datetime "created_at"
    end

    add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
    add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

    create_table "tags", force: true do |t|
      t.string  "name"
      t.integer "taggings_count", default: 0
    end

    add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

    create_table "topics", force: true do |t|
      t.string   "name",                          null: false
      t.text     "description"
      t.string   "url"
      t.integer  "minutes"
      t.boolean  "inactive",      default: false
      t.boolean  "certificate",   default: false
      t.integer  "survey_type",   default: 1
      t.string   "survey_url"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "department_id"
    end

    add_index "topics", ["department_id"], name: "index_topics_on_department_id", using: :btree

    create_table "users", force: true do |t|
      t.string   "login",                       null: false
      t.string   "email",                       null: false
      t.string   "first_name"
      t.string   "last_name",                   null: false
      t.string   "name_prefix"
      t.string   "title"
      t.string   "department"
      t.boolean  "admin",       default: false, null: false
      t.boolean  "boolean",     default: false, null: false
      t.boolean  "manual",      default: false, null: false
      t.boolean  "inactive",    default: false, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "users", ["email"], name: "index_users_on_email", using: :btree
    add_index "users", ["first_name"], name: "index_users_on_first_name", using: :btree
    add_index "users", ["last_name"], name: "index_users_on_last_name", using: :btree
    add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree

    create_table "versions", force: true do |t|
      t.string   "item_type",  null: false
      t.integer  "item_id",    null: false
      t.string   "event",      null: false
      t.string   "whodunnit"
      t.text     "object"
      t.datetime "created_at"
      t.string   "ip"
      t.text     "user_agent"
    end

    add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  end
end

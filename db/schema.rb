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

ActiveRecord::Schema.define(version: 20140524203522) do

  create_table "departments", force: true do |t|
    t.string   "name",                       null: false
    t.boolean  "inactive",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "occurrences", force: true do |t|
    t.integer  "session_id", null: false
    t.datetime "time",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reservations", force: true do |t|
    t.integer  "user_id",                                null: false
    t.integer  "session_id",                             null: false
    t.boolean  "cancelled",              default: false
    t.integer  "attended",               default: 0
    t.text     "special_accommodations"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reservations", ["session_id"], name: "index_reservations_on_session_id", using: :btree
  add_index "reservations", ["user_id"], name: "index_reservations_on_user_id", using: :btree

  create_table "sessions", force: true do |t|
    t.integer  "topic_id",                     null: false
    t.boolean  "cancelled",    default: false, null: false
    t.string   "location",                     null: false
    t.string   "location_url"
    t.integer  "site_id"
    t.integer  "seats"
    t.datetime "reg_start"
    t.datetime "reg_end"
    t.boolean  "survey_sent",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
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

  add_index "survey_responses", ["reservation_id"], name: "index_survey_responses_on_reservation_id", using: :btree

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
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end

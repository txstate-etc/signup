# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120920165906) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "departments", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", :force => true do |t|
    t.integer  "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "item_file_name"
    t.string   "item_content_type"
    t.integer  "item_file_size"
    t.datetime "item_updated_at"
  end

  create_table "email_logs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "session_id"
    t.string   "message_type"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "occurrences", :force => true do |t|
    t.integer  "session_id"
    t.datetime "time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "occurrences", ["session_id", "time"], :name => "unique_occurrence_times_in_session", :unique => true
  add_index "occurrences", ["session_id"], :name => "index_occurrences_on_session_id"

  create_table "permissions", :force => true do |t|
    t.integer  "department_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["department_id"], :name => "index_permissions_on_department_id"
  add_index "permissions", ["user_id"], :name => "index_permissions_on_user_id"

  create_table "reservations", :force => true do |t|
    t.integer  "user_id",                               :null => false
    t.integer  "session_id",                            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "attended",               :default => 0
    t.text     "special_accommodations"
  end

  create_table "sessions", :force => true do |t|
    t.integer  "topic_id",                       :null => false
    t.string   "location",                       :null => false
    t.boolean  "cancelled",   :default => false, :null => false
    t.integer  "seats"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "survey_sent", :default => false
    t.datetime "reg_start"
    t.datetime "reg_end"
  end

  create_table "sessions_users", :id => false, :force => true do |t|
    t.integer "session_id", :null => false
    t.integer "user_id",    :null => false
  end

  create_table "survey_responses", :force => true do |t|
    t.integer  "reservation_id"
    t.integer  "class_rating"
    t.integer  "instructor_rating"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "applicability"
    t.text     "most_useful"
  end

  create_table "topics", :force => true do |t|
    t.string   "name",                             :null => false
    t.text     "description"
    t.string   "url"
    t.integer  "minutes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "survey_type",   :default => 1
    t.string   "survey_url"
    t.integer  "department_id"
    t.boolean  "inactive",      :default => false
  end

  create_table "users", :force => true do |t|
    t.string   "login",                         :null => false
    t.string   "email",                         :null => false
    t.boolean  "admin",      :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     :default => true
    t.string   "department"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["active"], :name => "index_users_on_active"
  add_index "users", ["first_name"], :name => "index_users_on_first_name"
  add_index "users", ["last_name"], :name => "index_users_on_last_name"
  add_index "users", ["login"], :name => "index_users_on_login"

end

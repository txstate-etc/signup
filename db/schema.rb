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

ActiveRecord::Schema.define(:version => 20140216210000) do

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
    t.boolean  "inactive",   :default => false
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

  create_table "http_sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "http_sessions", ["session_id"], :name => "index_http_sessions_on_session_id"
  add_index "http_sessions", ["updated_at"], :name => "index_http_sessions_on_updated_at"

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
    t.integer  "user_id",                                   :null => false
    t.integer  "session_id",                                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "attended",               :default => 0
    t.text     "special_accommodations"
    t.boolean  "cancelled",              :default => false
  end

  create_table "sessions", :force => true do |t|
    t.integer  "topic_id",                        :null => false
    t.string   "location",                        :null => false
    t.boolean  "cancelled",    :default => false, :null => false
    t.integer  "seats"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "survey_sent",  :default => false
    t.datetime "reg_start"
    t.datetime "reg_end"
    t.integer  "site_id"
    t.string   "location_url"
  end

  create_table "sessions_users", :id => false, :force => true do |t|
    t.integer "session_id", :null => false
    t.integer "user_id",    :null => false
  end

  create_table "sites", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sites", ["name"], :name => "index_sites_on_name"

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

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
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
    t.boolean  "certificate",   :default => false
  end

  create_table "users", :force => true do |t|
    t.string   "login",                          :null => false
    t.string   "email",                          :null => false
    t.boolean  "admin",       :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",      :default => true
    t.string   "department"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "name_prefix"
    t.string   "title"
    t.boolean  "manual",      :default => false
    t.boolean  "inactive",    :default => false
  end

  add_index "users", ["active"], :name => "index_users_on_active"
  add_index "users", ["first_name"], :name => "index_users_on_first_name"
  add_index "users", ["last_name"], :name => "index_users_on_last_name"
  add_index "users", ["login"], :name => "index_users_on_login"

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.string   "ip"
    t.string   "user_agent"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end

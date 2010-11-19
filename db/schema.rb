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

ActiveRecord::Schema.define(:version => 20101116233846) do

  create_table "departments", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.text     "body"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.integer  "session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reservations", :force => true do |t|
    t.integer  "user_id",                               :null => false
    t.integer  "session_id",                            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "attended",               :default => 0
    t.text     "special_accommodations"
  end

  create_table "sessions", :force => true do |t|
    t.datetime "time",                           :null => false
    t.integer  "topic_id",                       :null => false
    t.string   "location",                       :null => false
    t.boolean  "cancelled",   :default => false, :null => false
    t.integer  "seats"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "survey_sent", :default => false
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
  end

  create_table "topics", :force => true do |t|
    t.string   "name",                         :null => false
    t.text     "description"
    t.string   "url"
    t.integer  "minutes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "survey_type",   :default => 1
    t.string   "survey_url"
    t.integer  "department_id"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                         :null => false
    t.string   "email",                         :null => false
    t.string   "name",                          :null => false
    t.boolean  "admin",      :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     :default => true
    t.string   "department"
  end

  add_index "users", ["active"], :name => "index_users_on_active"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["name"], :name => "index_users_on_name"

end

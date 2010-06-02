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

ActiveRecord::Schema.define(:version => 20100602210751) do

  create_table "admins", :force => true do |t|
    t.string   "login"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instructors", :force => true do |t|
    t.string   "name"
    t.string   "login"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reservations", :force => true do |t|
    t.string   "name"
    t.string   "login"
    t.integer  "session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.datetime "time"
    t.integer  "instructor_id"
    t.integer  "topic_id"
    t.string   "location"
    t.boolean  "cancelled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seats"
  end

  create_table "topics", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "url"
    t.integer  "minutes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

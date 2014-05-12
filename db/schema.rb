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

ActiveRecord::Schema.define(version: 20140512163306) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "documents", force: true do |t|
    t.integer  "folder_id"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  add_index "documents", ["creator_id"], name: "index_documents_on_creator_id", using: :btree
  add_index "documents", ["folder_id"], name: "index_documents_on_folder_id", using: :btree

  create_table "events", force: true do |t|
    t.string   "description"
    t.hstore   "data"
    t.text     "json_data"
    t.integer  "organization_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verb"
  end

  add_index "events", ["member_id"], name: "index_events_on_member_id", using: :btree
  add_index "events", ["organization_id"], name: "index_events_on_organization_id", using: :btree

  create_table "folders", force: true do |t|
    t.string   "name"
    t.boolean  "archived",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
  end

  add_index "folders", ["organization_id"], name: "index_folders_on_organization_id", using: :btree

  create_table "meetings", force: true do |t|
    t.integer  "room_id"
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "meetings", ["room_id"], name: "index_meetings_on_room_id", using: :btree

  create_table "members", force: true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "permissions",     default: "--- []\n"
    t.string   "key"
    t.hstore   "data",            default: {}
    t.string   "email"
  end

  add_index "members", ["organization_id"], name: "index_members_on_organization_id", using: :btree
  add_index "members", ["user_id"], name: "index_members_on_user_id", using: :btree

  create_table "organizations", force: true do |t|
    t.string   "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "modules",           default: "---\n- contacts\n"
    t.string   "name"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "rooms", force: true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rooms", ["organization_id"], name: "index_rooms_on_organization_id", using: :btree

  create_table "segments", force: true do |t|
    t.string   "name"
    t.text     "filters"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "segments", ["organization_id"], name: "index_segments_on_organization_id", using: :btree

  create_table "tasks", force: true do |t|
    t.text     "content"
    t.integer  "folder_id"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "complete",   default: false
    t.integer  "ordinal",    default: 9999
  end

  add_index "tasks", ["creator_id"], name: "index_tasks_on_creator_id", using: :btree
  add_index "tasks", ["folder_id"], name: "index_tasks_on_folder_id", using: :btree

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
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end

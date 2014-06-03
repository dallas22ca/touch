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

ActiveRecord::Schema.define(version: 20140603123638) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "comments", force: true do |t|
    t.integer  "folder_id"
    t.integer  "creator_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["creator_id"], name: "index_comments_on_creator_id", using: :btree
  add_index "comments", ["folder_id"], name: "index_comments_on_folder_id", using: :btree

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

  create_table "fields", force: true do |t|
    t.string   "name"
    t.string   "permalink"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fields", ["organization_id"], name: "index_fields_on_organization_id", using: :btree

  create_table "folders", force: true do |t|
    t.string   "name"
    t.boolean  "archived",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.integer  "creator_id"
  end

  add_index "folders", ["creator_id"], name: "index_folders_on_creator_id", using: :btree
  add_index "folders", ["organization_id"], name: "index_folders_on_organization_id", using: :btree

  create_table "folderships", force: true do |t|
    t.integer  "folder_id"
    t.integer  "member_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.boolean  "accepted",   default: false
    t.string   "token"
    t.string   "name"
    t.string   "email"
    t.text     "roles",      default: "--- []\n"
    t.string   "preset"
  end

  add_index "folderships", ["creator_id"], name: "index_folderships_on_creator_id", using: :btree
  add_index "folderships", ["folder_id"], name: "index_folderships_on_folder_id", using: :btree
  add_index "folderships", ["member_id"], name: "index_folderships_on_member_id", using: :btree

  create_table "homes", force: true do |t|
    t.string   "address"
    t.string   "city"
    t.string   "province"
    t.string   "postal_code"
    t.string   "beds"
    t.string   "baths"
    t.text     "data",         default: "{}"
    t.integer  "folder_id"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "price"
    t.text     "long_address"
    t.float    "longitude"
    t.float    "latitude"
  end

  add_index "homes", ["creator_id"], name: "index_homes_on_creator_id", using: :btree
  add_index "homes", ["folder_id"], name: "index_homes_on_folder_id", using: :btree

  create_table "identities", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "username"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.datetime "oauth_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "domain"
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

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
    t.text     "roles",           default: "--- []\n"
    t.boolean  "subscribed",      default: true
  end

  add_index "members", ["organization_id"], name: "index_members_on_organization_id", using: :btree
  add_index "members", ["user_id"], name: "index_members_on_user_id", using: :btree

  create_table "messages", force: true do |t|
    t.text     "subject"
    t.text     "body"
    t.text     "member_ids",      default: "--- []\n"
    t.integer  "organization_id"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "segment_ids",     default: "--- []\n"
  end

  add_index "messages", ["creator_id"], name: "index_messages_on_creator_id", using: :btree
  add_index "messages", ["organization_id"], name: "index_messages_on_organization_id", using: :btree

  create_table "organizations", force: true do |t|
    t.string   "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "modules",           default: "--- []\n"
    t.string   "name"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "website"
    t.integer  "members_count",     default: 0
    t.text     "full_address"
    t.string   "publishable_key"
    t.string   "secret_key"
  end

  create_table "rooms", force: true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
  end

  add_index "rooms", ["creator_id"], name: "index_rooms_on_creator_id", using: :btree
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
    t.boolean  "complete",     default: false
    t.integer  "ordinal",      default: 9999
    t.integer  "member_id"
    t.datetime "due_at"
    t.datetime "completed_at"
  end

  add_index "tasks", ["creator_id"], name: "index_tasks_on_creator_id", using: :btree
  add_index "tasks", ["folder_id"], name: "index_tasks_on_folder_id", using: :btree
  add_index "tasks", ["member_id"], name: "index_tasks_on_member_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",                           null: false
    t.string   "encrypted_password",     default: "",                           null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,                            null: false
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
    t.string   "phone"
    t.string   "website"
    t.string   "time_zone",              default: "Eastern Time (US & Canada)"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end

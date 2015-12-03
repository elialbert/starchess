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

ActiveRecord::Schema.define(version: 20151203001734) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ai_board_states", force: :cascade do |t|
    t.string   "state",      limit: 1000
    t.integer  "score"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "ai_board_states", ["state"], name: "index_ai_board_states_on_state", using: :btree

  create_table "attendrequests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "response"
    t.integer  "user_id"
    t.integer  "event_id"
    t.text     "message"
  end

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "image"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "min_attendees"
    t.integer  "max_attendees"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "creator_id"
    t.float    "lat"
    t.float    "lng"
  end

  add_index "events", ["creator_id"], name: "index_events_on_creator_id", using: :btree

  create_table "events_users", id: false, force: :cascade do |t|
    t.integer "event_id"
    t.integer "user_id"
  end

  add_index "events_users", ["event_id", "user_id"], name: "by event and user", unique: true, using: :btree
  add_index "events_users", ["event_id"], name: "index_events_users_on_event_id", using: :btree
  add_index "events_users", ["user_id"], name: "index_events_users_on_user_id", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_from_id"
    t.integer  "user_to_id"
    t.integer  "score"
    t.string   "blurb"
    t.integer  "event_id"
    t.boolean  "from_creator"
  end

  add_index "ratings", ["user_from_id"], name: "index_ratings_on_user_from_id", using: :btree
  add_index "ratings", ["user_to_id"], name: "index_ratings_on_user_to_id", using: :btree

  create_table "starchess_games", force: :cascade do |t|
    t.string   "turn"
    t.string   "mode"
    t.string   "board_state"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "winner_id"
    t.integer  "player1_id"
    t.integer  "player2_id"
    t.text     "chosen_pieces"
    t.string   "available_moves", limit: 700
  end

  add_index "starchess_games", ["player1_id"], name: "index_starchess_games_on_player1_id", using: :btree
  add_index "starchess_games", ["player2_id"], name: "index_starchess_games_on_player2_id", using: :btree
  add_index "starchess_games", ["winner_id"], name: "index_starchess_games_on_winner_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "default_location_string"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.float    "lat"
    t.float    "lng"
    t.string   "encrypted_password",      default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "provider"
    t.string   "uid"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["provider"], name: "index_users_on_provider", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

end

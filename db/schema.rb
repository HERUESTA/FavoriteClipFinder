# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_11_03_085653) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clips", force: :cascade do |t|
    t.string "clip_id", null: false
    t.string "streamer_id", null: false
    t.bigint "game_id", null: false
    t.string "title"
    t.datetime "clip_created_at", precision: nil
    t.string "thumbnail_url"
    t.integer "duration"
    t.integer "view_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "language"
    t.string "creator_name"
    t.index ["clip_created_at"], name: "index_clips_on_clip_created_at"
    t.index ["clip_id"], name: "index_clips_on_clip_id", unique: true
    t.index ["game_id", "clip_created_at"], name: "index_clips_on_game_id_and_clip_created_at"
    t.index ["game_id"], name: "index_clips_on_game_id"
    t.index ["streamer_id"], name: "index_clips_on_streamer_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name", null: false
    t.string "box_art_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "game_id"
    t.index ["game_id"], name: "index_games_on_game_id", unique: true
    t.index ["name"], name: "index_games_on_name", unique: true
  end

  create_table "streamers", force: :cascade do |t|
    t.string "streamer_id", null: false
    t.string "streamer_name", null: false
    t.string "profile_image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_name"
    t.index ["streamer_id"], name: "index_streamers_on_streamer_id", unique: true
    t.index ["streamer_name"], name: "index_streamers_on_streamer_name"
  end

  create_table "users", force: :cascade do |t|
    t.string "uid", default: "", null: false
    t.string "user_name"
    t.string "profile_image_url"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "email"
    t.string "encrypted_password"
    t.string "access_token"
    t.string "refresh_token"
    t.datetime "token_expires_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "clips", "games"
end

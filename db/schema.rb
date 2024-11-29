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

ActiveRecord::Schema[7.2].define(version: 2024_11_28_145631) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clips", force: :cascade do |t|
    t.string "clip_id", null: false
    t.string "streamer_id", null: false
    t.string "game_id", null: false
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

  create_table "favorite_clips", force: :cascade do |t|
    t.string "user_uid", null: false
    t.bigint "clip_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_uid", "clip_id"], name: "index_favorite_clips_on_user_uid_and_clip_id", unique: true
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

  create_table "playlist_clips", force: :cascade do |t|
    t.bigint "playlist_id", null: false
    t.bigint "clip_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clip_id"], name: "index_playlist_clips_on_clip_id"
    t.index ["playlist_id", "clip_id"], name: "index_playlist_clips_on_playlist_id_and_clip_id", unique: true
  end

  create_table "playlists", force: :cascade do |t|
    t.string "user_uid", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "visibility", default: "private", null: false
    t.boolean "is_watch_later", default: false, null: false
    t.integer "likes", default: 0, null: false
    t.index ["user_uid"], name: "index_playlists_on_user_uid"
  end

  create_table "streamers", force: :cascade do |t|
    t.string "streamer_id", null: false
    t.string "streamer_name", null: false
    t.string "profile_image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_name"
    t.index "lower((display_name)::text)", name: "index_streamers_on_lower_display_name"
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
    t.string "encrypted_password"
    t.string "access_token"
    t.string "refresh_token"
    t.datetime "token_expires_at"
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "clips", "games", primary_key: "game_id"
  add_foreign_key "clips", "streamers", primary_key: "streamer_id"
  add_foreign_key "favorite_clips", "clips"
  add_foreign_key "favorite_clips", "users", column: "user_uid", primary_key: "uid"
  add_foreign_key "playlist_clips", "clips"
  add_foreign_key "playlist_clips", "playlists"
  add_foreign_key "playlists", "users", column: "user_uid", primary_key: "uid"
end

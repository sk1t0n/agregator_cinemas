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

ActiveRecord::Schema.define(version: 20170718150807) do

  create_table "cinemas", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.text "description"
    t.text "equipment"
    t.text "contacts"
    t.text "discounts"
    t.string "logo"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genre_movies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "genre_id"
    t.bigint "movie_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "index_genre_movies_on_genre_id"
    t.index ["movie_id"], name: "index_genre_movies_on_movie_id"
  end

  create_table "genres", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movie_sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.date "date"
    t.time "time"
    t.string "format"
    t.integer "price"
    t.bigint "cinema_id"
    t.bigint "movie_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cinema_id"], name: "index_movie_sessions_on_cinema_id"
    t.index ["movie_id"], name: "index_movie_sessions_on_movie_id"
  end

  create_table "movies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.text "description"
    t.string "duration"
    t.string "age_rating"
    t.string "country"
    t.string "director"
    t.string "budget"
    t.text "actors"
    t.text "trailer"
    t.text "images"
    t.date "premiere"
    t.float "rating_kinopoisk", limit: 24
    t.integer "voice_kinopoisk"
    t.float "rating_imdb", limit: 24
    t.integer "voice_imdb"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "genre_movies", "genres"
  add_foreign_key "genre_movies", "movies"
  add_foreign_key "movie_sessions", "cinemas"
  add_foreign_key "movie_sessions", "movies"
end

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

ActiveRecord::Schema.define(version: 20161228111654) do

  create_table "interest_points", force: :cascade do |t|
    t.integer  "picture_id", limit: 4
    t.float    "x",          limit: 24
    t.float    "y",          limit: 24
    t.float    "scale",      limit: 24
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "interest_points", ["picture_id"], name: "index_interest_points_on_picture_id", using: :btree

  create_table "n_networks", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.float    "learning_rate", limit: 24
    t.integer  "repeat_cnt",    limit: 4
    t.integer  "hidden_size",   limit: 4
    t.text     "weights",       limit: 16777215
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "pictures", force: :cascade do |t|
    t.integer  "n_network_id",       limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
  end

  add_index "pictures", ["n_network_id"], name: "index_pictures_on_n_network_id", using: :btree

end

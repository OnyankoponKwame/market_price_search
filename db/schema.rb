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

ActiveRecord::Schema.define(version: 2022_05_20_015252) do

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.integer "price"
    t.integer "sold"
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "search_condition_id"
    t.index ["search_condition_id"], name: "index_items_on_search_condition_id"
  end

  create_table "search_conditions", force: :cascade do |t|
    t.string "keyword"
    t.integer "item_condition"
    t.integer "price_min"
    t.integer "price_max"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "negative_keyword"
    t.boolean "include_title_flag", default: false
    t.boolean "cron_flag", default: false
  end

  create_table "words", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "items", "search_conditions"
end

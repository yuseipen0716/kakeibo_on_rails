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

ActiveRecord::Schema[7.0].define(version: 2023_09_12_131941) do
  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expense_records", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "category_id", null: false
    t.integer "expense_type", default: 0, null: false
    t.integer "amount", null: false
    t.datetime "transaction_date", null: false
    t.text "memorandum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_expense_records_on_category_id"
    t.index ["user_id"], name: "index_expense_records_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer "group_id"
    t.text "line_id"
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_users_on_group_id"
    t.index ["line_id"], name: "index_users_on_line_id", unique: true
  end

  add_foreign_key "expense_records", "categories"
  add_foreign_key "expense_records", "users"
  add_foreign_key "users", "groups"
end

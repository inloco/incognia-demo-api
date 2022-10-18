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

ActiveRecord::Schema[7.0].define(version: 2022_10_18_121903) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assessment_logs", force: :cascade do |t|
    t.string "api_name"
    t.string "incognia_id"
    t.string "incognia_signup_id"
    t.string "account_id"
    t.string "installation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "signin_codes", force: :cascade do |t|
    t.string "code"
    t.datetime "expires_at", precision: nil
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "used_at", precision: nil
    t.index ["user_id"], name: "index_signin_codes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.json "address"
    t.string "incognia_signup_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "account_id"
    t.string "email"
    t.index ["email"], name: "index_signups_on_email", unique: true
  end

  add_foreign_key "signin_codes", "users"
end

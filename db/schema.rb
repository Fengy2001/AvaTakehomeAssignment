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

ActiveRecord::Schema[8.1].define(version: 2026_10_04_081524) do
  create_table "addresses", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.string "unit_street"
    t.string "city"
    t.string "province"
    t.string "postal"
    t.index ["patient_id"], name: "index_addresses_on_patient_id", unique: true
  end

  create_table "patient_contacts", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.string "contact_type", null: false
    t.string "value", null: false
    t.index ["patient_id"], name: "index_patient_contacts_on_patient_id"
  end

  create_table "patients", force: :cascade do |t|
    t.integer "health_id", null: false
    t.string "health_identifier_provider", null: false
    t.string "first_name", null: false
    t.string "middle_name"
    t.string "last_name", null: false
    t.date "dob", null: false
    t.string "sex", null: false
    t.datetime "updated_on", null: false
    t.index ["health_id"], name: "index_patients_on_health_id"
  end

  create_table "uncategorizeds", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.json "misc", null: false
    t.index ["patient_id"], name: "index_uncategorizeds_on_patient_id", unique: true
  end

  add_foreign_key "addresses", "patients"
  add_foreign_key "patient_contacts", "patients"
  add_foreign_key "uncategorizeds", "patients"
end

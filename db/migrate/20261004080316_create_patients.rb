class CreatePatients < ActiveRecord::Migration[8.1]
  def change
    create_table :patients do |t|
      t.integer :health_id, null: false, index: true
      t.string :health_identifier_provider, null: false
      t.string :first_name, null: false
      t.string :middle_name
      t.string :last_name, null: false
      t.date :dob, null: false
      t.string :sex, null: false
      t.datetime :updated_on, null: false
    end
  end
end
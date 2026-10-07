class CreatePatientContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :patient_contacts do |t|
      t.references :patient, null: false, foreign_key: true
      t.string :contact_type, null: false
      t.string :value, null: false
    end
  end
end
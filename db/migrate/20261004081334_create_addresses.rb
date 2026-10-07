class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :patient, null: false, foreign_key: true, index: {unique: true}
      t.string :unit_street
      t.string :city
      t.string :province
      t.string :postal
    end
  end
end
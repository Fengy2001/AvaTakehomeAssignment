class CreateUncategorizeds < ActiveRecord::Migration[8.1]
  def change
    create_table :uncategorizeds do |t|
      t.references :patient, null: false, foreign_key: true, index: {unique: true}
      t.json :misc, null: false
    end
  end
end
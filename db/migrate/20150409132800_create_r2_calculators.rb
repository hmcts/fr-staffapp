class CreateR2Calculators < ActiveRecord::Migration
  def change
    create_table :r2_calculators do |t|
      t.decimal :fee
      t.boolean :married
      t.integer :children
      t.decimal :income
      t.decimal :remittance
      t.decimal :to_pay
      t.references :created_by, references: :users, index: true

      t.timestamps null: false
    end
    add_foreign_key :r2_calculators, :users, column: :created_by_id
  end
end

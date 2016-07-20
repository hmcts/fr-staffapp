class AddIncomeThresholdsToApplication < ActiveRecord::Migration
  def change
    change_table :applications do |t|
      t.boolean :income_min_threshold_exceeded, null: true
      t.boolean :income_max_threshold_exceeded, null: true
    end
  end
end

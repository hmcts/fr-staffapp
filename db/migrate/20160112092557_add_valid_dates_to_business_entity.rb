class AddValidDatesToBusinessEntity < ActiveRecord::Migration
  def up
    add_column :business_entities, :valid_from, :datetime
    add_column :business_entities, :valid_to, :datetime
    remove_index :business_entities, name: :unique_office_jurisdiction
    add_index :business_entities, [:office_id, :jurisdiction_id, :valid_to], name: :unique_active_office_jurisdiction
    execute('UPDATE business_entities SET valid_from = created_at')
  end

  def down
    remove_column :business_entities, :valid_from
    remove_column :business_entities, :valid_to
    remove_index :business_entities, name: :unique_active_office_jurisdiction
    add_index :business_entities, [:office_id, :jurisdiction_id], unique: true, name: :unique_office_jurisdiction
  end
end

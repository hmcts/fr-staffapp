class AddFormTypeAndAddClaimTypeApplicationDetails < ActiveRecord::Migration[7.1]
  def change
    add_column :details, :form_type, :string
    add_column :details, :claim_type, :string, null: true
  end
end

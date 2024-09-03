class AddFormTypeAndAddClaimTypeOnlineApplicationDetails < ActiveRecord::Migration[7.1]
  def change
    add_column :online_applications, :form_type, :string
    add_column :online_applications, :claim_type, :string, null: true
  end
end

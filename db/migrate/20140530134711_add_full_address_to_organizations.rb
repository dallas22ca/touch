class AddFullAddressToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :full_address, :text
  end
end

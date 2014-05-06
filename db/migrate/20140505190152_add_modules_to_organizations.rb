class AddModulesToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :modules, :text, default: ["Contacts"]
  end
end

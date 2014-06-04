class AddImportingToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :importing, :boolean, default: false
    add_column :organizations, :import_progress, :string
  end
end

class AddKeysToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :publishable_key, :string
    add_column :organizations, :secret_key, :string
  end
end

class AddOrganizationToFolders < ActiveRecord::Migration
  def change
    add_reference :folders, :organization, index: true
  end
end

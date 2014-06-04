class AddAttachmentMembersImportToOrganizations < ActiveRecord::Migration
  def self.up
    change_table :organizations do |t|
      t.attachment :members_import
    end
  end

  def self.down
    drop_attached_file :organizations, :members_import
  end
end

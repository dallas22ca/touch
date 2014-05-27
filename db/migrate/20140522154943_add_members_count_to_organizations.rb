class AddMembersCountToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :members_count, :integer, default: 0
  end
end

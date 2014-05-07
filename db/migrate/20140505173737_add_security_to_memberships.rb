class AddSecurityToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :permissions, :text, default: []
  end
end

class AddSecurityToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :security, :string
  end
end

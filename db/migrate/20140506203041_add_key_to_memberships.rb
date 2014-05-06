class AddKeyToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :key, :string
  end
end

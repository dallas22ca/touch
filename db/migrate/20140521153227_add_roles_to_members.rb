class AddRolesToMembers < ActiveRecord::Migration
  def change
    add_column :members, :roles, :text, default: []
  end
end

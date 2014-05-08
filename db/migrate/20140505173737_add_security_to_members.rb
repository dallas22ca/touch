class AddSecurityToMembers < ActiveRecord::Migration
  def change
    add_column :members, :permissions, :text, default: []
  end
end

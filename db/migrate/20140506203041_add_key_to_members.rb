class AddKeyToMembers < ActiveRecord::Migration
  def change
    add_column :members, :key, :string
  end
end

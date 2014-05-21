class AddRolesToFolderships < ActiveRecord::Migration
  def change
    add_column :folderships, :roles, :text, default: []
  end
end

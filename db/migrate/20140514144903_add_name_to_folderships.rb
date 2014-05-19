class AddNameToFolderships < ActiveRecord::Migration
  def change
    add_column :folderships, :name, :string
    add_column :folderships, :email, :string
  end
end

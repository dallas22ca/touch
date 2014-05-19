class AddAcceptedToFolderships < ActiveRecord::Migration
  def change
    add_column :folderships, :accepted, :boolean, default: false
    add_column :folderships, :token, :string
  end
end

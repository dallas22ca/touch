class AddPresetToFolderships < ActiveRecord::Migration
  def change
    add_column :folderships, :preset, :string
  end
end

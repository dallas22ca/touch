class AddCreatorToFolders < ActiveRecord::Migration
  def change
    add_reference :folders, :creator, index: true
  end
end

class AddCreatorToFolderships < ActiveRecord::Migration
  def change
    add_reference :folderships, :creator, index: true
  end
end

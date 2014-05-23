class AddCreatorToRooms < ActiveRecord::Migration
  def change
    add_reference :rooms, :creator, index: true
  end
end

class UpdateRoomCreators < ActiveRecord::Migration
  def change
    Room.find_each do |room|
      room.update creator: room.organization.admins.first
    end
  end
end

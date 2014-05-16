class AddCreatorToChannelships < ActiveRecord::Migration
  def change
    add_reference :channelships, :creator, index: true
  end
end

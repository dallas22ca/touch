class AddCreatorToChannels < ActiveRecord::Migration
  def change
    add_reference :channels, :creator, index: true
  end
end

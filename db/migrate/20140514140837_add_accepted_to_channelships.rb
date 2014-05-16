class AddAcceptedToChannelships < ActiveRecord::Migration
  def change
    add_column :channelships, :accepted, :boolean, default: false
    add_column :channelships, :token, :string
  end
end

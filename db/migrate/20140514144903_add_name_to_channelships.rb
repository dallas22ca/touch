class AddNameToChannelships < ActiveRecord::Migration
  def change
    add_column :channelships, :name, :string
    add_column :channelships, :email, :string
  end
end

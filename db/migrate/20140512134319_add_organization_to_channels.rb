class AddOrganizationToChannels < ActiveRecord::Migration
  def change
    add_reference :channels, :organization, index: true
  end
end

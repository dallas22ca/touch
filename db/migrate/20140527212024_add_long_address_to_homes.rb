class AddLongAddressToHomes < ActiveRecord::Migration
  def change
    add_column :homes, :long_address, :text
    add_column :homes, :longitude, :float
    add_column :homes, :latitude, :float
  end
end

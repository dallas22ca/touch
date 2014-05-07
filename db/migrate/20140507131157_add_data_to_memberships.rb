class AddDataToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :data, :hstore, default: {}
  end
end

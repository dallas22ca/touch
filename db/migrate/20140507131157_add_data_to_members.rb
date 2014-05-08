class AddDataToMembers < ActiveRecord::Migration
  def change
    add_column :members, :data, :hstore, default: {}
  end
end

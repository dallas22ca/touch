class AddAvailabilityToMembers < ActiveRecord::Migration
  def change
    add_column :members, :availability, :text, default: [1, 2, 3, 4, 5]
  end
end

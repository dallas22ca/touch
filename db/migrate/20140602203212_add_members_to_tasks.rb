class AddMembersToTasks < ActiveRecord::Migration
  def change
    add_reference :tasks, :member, index: true
  end
end

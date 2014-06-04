class AddContactToTasks < ActiveRecord::Migration
  def change
    add_reference :tasks, :contact, index: true
  end
end

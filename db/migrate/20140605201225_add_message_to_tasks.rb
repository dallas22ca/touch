class AddMessageToTasks < ActiveRecord::Migration
  def change
    add_reference :tasks, :message, index: true
  end
end

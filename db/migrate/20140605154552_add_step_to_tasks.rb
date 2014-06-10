class AddStepToTasks < ActiveRecord::Migration
  def change
    add_reference :tasks, :step, index: true
  end
end

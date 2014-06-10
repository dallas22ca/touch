class AddYearToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :year, :integer
  end
end

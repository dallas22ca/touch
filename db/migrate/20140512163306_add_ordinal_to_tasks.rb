class AddOrdinalToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :ordinal, :integer, default: 9999
  end
end

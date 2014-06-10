class AddTemplateToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :template, :boolean, default: false
  end
end

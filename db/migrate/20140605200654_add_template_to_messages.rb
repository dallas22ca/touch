class AddTemplateToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :template, :boolean, default: false
  end
end

class AddToToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :to, :text
  end
end

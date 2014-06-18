class AddViaToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :via, :string, default: "email"
  end
end

class ChangeBitliesHrefColumnType < ActiveRecord::Migration
  def change
    change_column :bitlies, :href, :text
  end
end

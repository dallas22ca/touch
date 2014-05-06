class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :permalink

      t.timestamps
    end
  end
end

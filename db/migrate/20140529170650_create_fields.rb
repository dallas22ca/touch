class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :name
      t.string :permalink
      t.belongs_to :organization, index: true

      t.timestamps
    end
  end
end

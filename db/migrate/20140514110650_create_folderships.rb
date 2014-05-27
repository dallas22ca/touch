class CreateFolderships < ActiveRecord::Migration
  def change
    create_table :folderships do |t|
      t.belongs_to :folder, index: true
      t.belongs_to :member, index: true
      t.string :role

      t.timestamps
    end
  end
end

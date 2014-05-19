class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.belongs_to :folder, index: true
      t.belongs_to :creator, index: true
      t.text :body

      t.timestamps
    end
  end
end

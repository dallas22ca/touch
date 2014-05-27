class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.belongs_to :folder, index: true
      t.belongs_to :creator, index: true

      t.timestamps
    end
  end
end
